

# 格web3导航网站

一个基于 Spring Boot + Vue 前后端分离的导航网站系统，在线演示地址：[https://gesdh.cn](https://gesdh.cn)


## 运行

前端：需要搭建 Vue 脚手架环境，如：安装 Node.js、Vue-cli 。

后端：需要搭建 Java 开发环境。此外，还需要安装 MySQL 数据库（推荐 MySQL 8）、Redis。

#### 前端运行

```bash
# 进入项目目录
cd vue-geshanzsq-nav

# 安装依赖
npm install

# 建议不要直接使用 cnpm 安装依赖，会有各种诡异的 bug。可以通过如下操作解决 npm 下载速度慢的问题
npm install --registry=https://registry.npm.taobao.org

# 启动服务
npm run dev
```

浏览器访问 http://localhost:80

#### 后端运行

新建数据库，导入数据：

```
geshanzsq-nav.sql
```

在 geshanzsq-nav-admin 模块下，有三个配置文件：

| application.yml            | application-dev.yml                               | application-prod.yml                              |
| -------------------------- | ------------------------------------------------- | ------------------------------------------------- |
| 主要配置文件，配置公共信息 | 开发环境，配置 MySQL 数据库、Redis 缓存、文件路径 | 生产环境，配置 MySQL 数据库、Redis 缓存、文件路径 |

![image-20210104230828122](https://i.loli.net/2021/01/04/PRSzfusxb1dOo5A.png)

在开发环境的 application-dev.yml 配置文件中，配置 MySQL 数据库连接信息、Redis 缓存、网站初始化图片。

![image-20210104231437985](https://i.loli.net/2021/01/04/D2TC8js5zHv9VIB.png)

![image-20210104231513623](https://i.loli.net/2021/01/04/hgUZjcb7CGtF2ne.png)

![image-20210104231626229](https://i.loli.net/2021/01/04/ozpRGUjWhk6gv7c.png)

**注：** 需要把目录【网站图片】下的 profile.zip 解压到配置文件的文件路径中，否则内置的网站数据加载不出图片。比如我的是：E:/home/geshanzsq-nav/uploadPath/profile

##### 生产环境

配置对应的 MySQL 数据库、Redis 环境、文件路径。在 application.yml 配置文件中，把 dev 改为 prod。

![image-20210104232641437](https://i.loli.net/2021/01/04/cepE3wfOSU97xRY.png)

## 使用

导航首页：http://127.0.0.1

登录地址：http://127.0.0.1/login

默认用户：admin

默认密码：admin123

## 演示图

![image-20210106205920036](https://i.loli.net/2021/01/06/6mtepGbF5IVWELz.png)



![image-20210106205947129](https://i.loli.net/2021/01/06/O5c8ApDjZX9VMa4.png)



![image-20210106210030366](https://i.loli.net/2021/01/06/j3eVRAKpShXD17C.png)



![image-20210106210109976](https://i.loli.net/2021/01/06/X3I6VyRYOTMJW7H.png)



![image-20210106210147466](https://i.loli.net/2021/01/06/uItNSPi4Vzj6Zqy.png)



![image-20210106210239126](https://i.loli.net/2021/01/06/rR7LAk8WSUJysXK.png)

## 项目部署

最近有挺多小伙伴不知道如何部署到服务器，小格子给大家简单的介绍一下。

### 安装相关环境

首先需要有一台服务器（建议 Linux 系统），安装 JDK1.8、MySQL 数据库、Redis 缓存、Nginx 代理。不会安装的请看这几篇文章。

[Linux 安装 MySQL 8 数据库](https://geshanzsq.com/article/34)

[Linux 安装 Nginx 代理](https://geshanzsq.com/article/65)

前端打包后会生成 dist，上传到服务器对应目录。后端打包为 Jar 包，上传到服务器对应目录并执行下面命令：

```shell
nohup java -jar geshanzsq-nav-admin.jar &
```

### Nginx 代理配置

为了保证前端和后端不存在跨域问题，需要部署在 Nginx 进行配置：

```nginx
server {
    listen       80;
    server_name  localhost;
    
    # 前端项目配置
    location / {
        # root 后面为项目存在目录
        root /home/project/geshanzsq-nav/dist;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
   }
    
   # 后端项目配置
   location /prod-api/ {
        # 项目 IP 地址和端口，如果不在一台服务器，请填写对应的 IP；如果后端端口修改后，请填写修改后的端口
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  } 
}

```

## License

Copyright © 2020-2022 **[格姗知识圈导航](https://gesdh.cn)** Released under the **MIT License**.

> 注：本导航开源的目的是大家能够在本站的基础之上有所启发，做出更多新的东西，比如自定义导航。并不是让大家照搬所有代码。 如果你使用这个开源项目，请**注明**本项目开源地址。

## 感谢

若依后台管理系统：[RuoYi-Vue](https://gitee.com/y_project/RuoYi-Vue)

花裤衩：[vue-element-admin](https://gitee.com/panjiachen/vue-element-admin)