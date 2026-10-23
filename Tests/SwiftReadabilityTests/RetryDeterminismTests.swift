import Foundation
import Testing
@testable import SwiftReadability

/// A page shorter than `charThreshold` takes the retry path, which restores the page HTML and so frees the previous
/// attempt's nodes. Caches keyed by `ObjectIdentifier` that outlive that restore can hand a new node the text length
/// or link density of a freed one at the same address, so the same bytes could give different content. Every
/// per-node cache is now cleared between attempts; this parses one such page many times and expects one result.
struct RetryDeterminismTests {
    private let baseURL = URL(string: "https://radio.example.test/2026/10/22/ferry-strike")!

    private let html = """
        <!DOCTYPE html><html><head><title>Ferry crews walk out : Example Radio</title></head><body>
        <div class="speakable"><b>Ferry crews walk out over a winter timetable</b> <b>Ferry crews in an invented town \
        stopped work at dawn, saying the new timetable had been drawn up without them.</b></div>
        <div id="wrapper"><section><article class="story">
        <div class="storytitle"><h1>Ferry crews walk out over a winter timetable</h1></div>
        <div class="story-meta"><div class="dateblock"><time><span>October 22, 2026</span><span>4:56 AM ET</span>\
        </time></div><div class="program-block">Heard on <a href="/programs/morning">Morning Show</a></div></div>
        <div class="audio-module"><h4>Ferry crews walk out over a winter timetable</h4>
        <button><b class="label">Toggle more options</b></button>
        <div class="audio-embed-overlay"><label><b>Embed</b><input value="&lt;iframe src=&quot;x&quot;&gt;"></label>
        <b><code>&lt;iframe src="https://radio.example.test/player/embed/1"&gt;</code></b></div></div>
        <div id="storytext" class="storytext"><p>Ferry crews in an invented town stopped work at dawn, saying the new \
        timetable had been drawn up without them.</p>
        <aside class="ad-wrap"><span>Sponsor Message</span></aside></div>
        <div class="notice"><p><strong>Example Radio takes no money for coverage</strong><br>of any kind.</p></div>
        </article></section></div></body></html>
        """

    @Test func shortPageParsesToOneResult() throws {
        var contents = Set<String>()
        for _ in 0..<200 {
            let result = try Readability(html: html, url: baseURL).parse()
            contents.insert(result?.content ?? "")
        }
        #expect(contents.count == 1)
    }
}
