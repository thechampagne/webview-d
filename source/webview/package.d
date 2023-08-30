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
module webview;

import std.string : toStringz;
import webview.raw;

alias WebViewVersionInfo = webview_version_info_t;

extern(C) alias DispatchCallback = void function (webview_t w, void* arg);

extern(C) alias BindCallback = void function (const(char)* seq, const(char)* req, void* arg);

enum WindowSizeHint
{
 None,
 Min,
 Max,
 Fixed
}

struct WebView
{
  private webview_t webview;

  this(bool debug_, void* window)
  {
    webview = webview_create(cast(int)debug_, window);
  }

  void run()
  {
    webview_run(this.webview);
  }

  void terminate()
  {
    webview_terminate(this.webview);
  }

  void dispatch(DispatchCallback fn, void* arg)
  {
    webview_dispatch(this.webview, fn, arg);
  }

  void* getWindow()
  {
    return webview_get_window(this.webview);
  }

  void setTitle(string title)
  {
    webview_set_title(this.webview, title.toStringz);
  }

  void setSize(int width, int height, WindowSizeHint hint)
  {
    webview_set_size(this.webview, width, height, cast(int)hint);
  }

  void navigate(string url)
  {
    webview_navigate(this.webview, url.toStringz);
  }

  void setHtml(string html)
  {
    webview_set_html(this.webview, html.toStringz);
  }

  void init(string js)
  {
    webview_init(this.webview, js.toStringz);
  }

  void eval(string js)
  {
    webview_eval(this.webview, js.toStringz);
  }

  void bind(string name, BindCallback fn, void* arg)
  {
    webview_bind(this.webview, name.toStringz, fn, arg);
  }

  void unbind(string name)
  {
    webview_unbind(this.webview, name.toStringz);
  }

  void ret(string seq, int status, string result)
  {
    webview_return(this.webview, seq.toStringz, status, result.toStringz);
  }

  const(WebViewVersionInfo)* ver()
  {
    return webview_version();
  }

  ~this()
  {
    webview_destroy(this.webview);
  }
}
