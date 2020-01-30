# MyerSplash for iOS

![](./design/hero.jpg)

## Introduction
Yet anothor simple and elegant photos & wallpaper app for all platforms.

Welcome to visit the [Android](https://github.com/JuniperPhoton/MyerSplash.Android) and [UWP](https://github.com/JuniperPhoton/MyerSplash.UWP) version :)

## Download

Visit the [website](https://juniperphoton.dev/myersplash/) to download all versions.

## Building

MyerSplash for iOS is a standard iOS project. Just open it with Xcode and see what will happen.

Note that in order to access the unsplash API, you must:

- Register as developer in unsplash.com
- Copy your app secret key

Then create a `Key.plist` file in root dir and paste the key-values:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AppCenterKey</key>
	<string>xxxxx</string>
	<key>UnsplashKey</key>
	<string>xxxx</string>
</dict>
</plist>

```

This app uses Microsoft's AppCenter to do the analysis, thus you should also have the appcenterKey too.

## License 
The project is released under MIT License.

MIT License

Copyright (c) 2020 JuniperPhoton

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

