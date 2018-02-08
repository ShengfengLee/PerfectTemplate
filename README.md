

## 编译运行

下列命令行可以克隆并在8282端口编译并启动 HTTP 服务器：

```
git https://github.com/ShengfengLee/PerfectTemplate.git
cd PerfectTemplate
swift build
.build/debug/PerfectTemplate
```

如果没有问题，输出应该看起来像是这样：

```
[INFO] Starting HTTP server MyServer on 0.0.0.0:8282
```

这表明服务器已经准备好并且等待连接了。请访问[http://localhost:8282/](http://127.0.0.1:8282/) 来查看欢迎信息。在终端命令行上输入control-c组合键即可停止Web服务。
