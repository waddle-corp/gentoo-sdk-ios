Pod::Spec.new do |spec|
    spec.name         = "GentooSDK"
    spec.version      = "1.0.0"
    spec.summary      = "iOS SDK for interactive AI agent Gentoo"
    spec.homepage     = "https://github.com/waddle-corp/gentoo-sdk-ios"
    spec.license      = { :type => 'MIT', :text => <<-LICENSE
    	MIT License

	Copyright (c) 2024 WADDLE Corp

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
	LICENSE
  }
    spec.author       = "WADDLE Corp"
    spec.ios.deployment_target = '12.0'
    spec.source       = { :http => "https://github.com/waddle-corp/gentoo-sdk-ios/releases/download/1.0.0/GentooSDK.xcframework.zip" }
    spec.vendored_frameworks = "GentooSDK.xcframework"
end