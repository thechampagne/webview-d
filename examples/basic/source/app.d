import webview;

void main()
{
  WebView w = WebView(false, null);
  w.setTitle("Basic Example");
  w.setSize(480, 320, WindowSizeHint.None);
  w.setHtml("Thanks for using webview!");
  w.run();
}
