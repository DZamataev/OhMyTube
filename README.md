About
=====

This project is an Open Source iOS Application that features download videos from YouTube and watch them offline, e.g. YouTube video downloader for iOS.

The application consists of two main parts (tabs):
* Browser that lets you browse YouTube website and pick videos to download. 
The codebase might be interesting for you, because the implementation is all about WKWebView (pretty new tech atow), with custom JavaScript that helps to catch and handle pushstate changes in WebView for single-page application (YouTube is that kind).
* Downloads list with Video Player that is a separate lib (https://github.com/DZamataev/DZVideoPlayerController), developed for this App. It features video playback with basic UI controls, MPRemoteCommandCenter integration, MPNowPlayingInfoCenter updates,  and background video playback support.

The application uses Dependency Injection powered by Objection (https://github.com/atomicobject/objection).

The application uses XCDYouTubeKit (https://github.com/0xced/XCDYouTubeKit) to get stream URL to download mp4 file from YouTube.
XCDYouTubeKit is against the YouTube Terms of Service. The only official way of playing a YouTube video inside an app is with a web view and the iframe player API.

In fact this app does not actually play YouTube video (in terms of streaming), but play downloaded .mp4 file. So it might be OK with YouTube ToS, but i'm not sure about it.

Requirements
============

Runs on iOS 8.0 and later

Install
=======

Download, open in Xcode (version 6.0.0 or later) and run.

License
=======

Copyright (c) 2015, Denis Zamataev All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
