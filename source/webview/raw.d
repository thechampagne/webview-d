/*
 * Copyright (c) 2023 XXIV
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module webview.raw;

extern (C):

// Documentation copied from https://github.com/webview/webview/blob/master/webview.h

// The current library major version.
enum WEBVIEW_VERSION_MAJOR = 0;

// The current library minor version.
enum WEBVIEW_VERSION_MINOR = 10;

// The current library patch version.
enum WEBVIEW_VERSION_PATCH = 0;

// version number in MAJOR.MINOR.PATCH format.
enum WEBVIEW_VERSION_NUMBER = "0.10.0";

// Holds the elements of a MAJOR.MINOR.PATCH version number.
struct webview_version_t
{
    // Major version.
    uint major;
    // Minor version.
    uint minor;
    // Patch version.
    uint patch;
}

// Holds the library's version information.
struct webview_version_info_t
{
    // The elements of the version number.
    webview_version_t version_;
    // SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.
    char[32] version_number;
    // SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
    // an empty string.
    char[48] pre_release;
    // SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.
    char[48] build_metadata;
}

alias webview_t = void*;

// Creates a new webview instance. If debug is non-zero - developer tools will
// be enabled (if the platform supports them). The window parameter can be a
// pointer to the native window handle. If it's non-null - then child WebView
// is embedded into the given parent window. Otherwise a new window is created.
// Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
// passed here. Returns null on failure. Creation can fail for various reasons
// such as when required runtime dependencies are missing or when window creation
// fails.
webview_t webview_create (int debug_, void* window);

// Destroys a webview and closes the native window.
void webview_destroy (webview_t w);

// Runs the main loop until it's terminated. After this function exits - you
// must destroy the webview.
void webview_run (webview_t w);

// Stops the main loop. It is safe to call this function from another other
// background thread.
void webview_terminate (webview_t w);

// Posts a function to be executed on the main thread. You normally do not need
// to call this function, unless you want to tweak the native window.
void webview_dispatch (
    webview_t w,
    void function (webview_t w, void* arg) fn,
    void* arg);

// Returns a native window handle pointer. When using a GTK backend the pointer
// is a GtkWindow pointer, when using a Cocoa backend the pointer is a NSWindow
// pointer, when using a Win32 backend the pointer is a HWND pointer.
void* webview_get_window (webview_t w);

// Updates the title of the native window. Must be called from the UI thread.
void webview_set_title (webview_t w, const(char)* title);

// Window size hints
enum WEBVIEW_HINT_NONE = 0; // Width and height are default size
enum WEBVIEW_HINT_MIN = 1; // Width and height are minimum bounds
enum WEBVIEW_HINT_MAX = 2; // Width and height are maximum bounds
enum WEBVIEW_HINT_FIXED = 3; // Window size can not be changed by a user
// Updates the size of the native window. See WEBVIEW_HINT constants.
void webview_set_size (webview_t w, int width, int height, int hints);

// Navigates webview to the given URL. URL may be a properly encoded data URI.
// Examples:
// webview_navigate(w, "https://github.com/webview/webview");
// webview_navigate(w, "data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
// webview_navigate(w, "data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
void webview_navigate (webview_t w, const(char)* url);

// Set webview HTML directly.
// Example: webview_set_html(w, "<h1>Hello</h1>");
void webview_set_html (webview_t w, const(char)* html);

// Injects JavaScript code at the initialization of the new page. Every time
// the webview will open a new page - this initialization code will be
// executed. It is guaranteed that code is executed before window.onload.
void webview_init (webview_t w, const(char)* js);

// Evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
// the result of the expression is ignored. Use RPC bindings if you want to
// receive notifications about the results of the evaluation.
void webview_eval (webview_t w, const(char)* js);

// Binds a native C callback so that it will appear under the given name as a
// global JavaScript function. Internally it uses webview_init(). The callback
// receives a sequential request id, a request string and a user-provided
// argument pointer. The request string is a JSON array of all the arguments
// passed to the JavaScript function.
void webview_bind (
    webview_t w,
    const(char)* name,
    void function (const(char)* seq, const(char)* req, void* arg) fn,
    void* arg);

// Removes a native C callback that was previously set by webview_bind.
void webview_unbind (webview_t w, const(char)* name);

// Allows to return a value from the native binding. A request id pointer must
// be provided to allow the internal RPC engine to match requests and responses.
// If the status is zero - the result is expected to be a valid JSON value.
// If the status is not zero - the result is an error JSON object.
void webview_return (
    webview_t w,
    const(char)* seq,
    int status,
    const(char)* result);

// Get the library's version information.
// @since 0.10
const(webview_version_info_t)* webview_version ();
