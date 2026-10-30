# 敢达OL模型与数据匹配台

本地运行的人工标注工具：预览自己提供的敢达OL DXG模型，选择与之对应的Wiki机体条目，保存模型、性能参考和武器参考之间的关联。

支持旋转/缩放、DDS贴图逐网格选择、部件显隐、线框、搜索、多选数据条目、备注、匹配进度筛选和JSON导出。右侧顶部保存栏滚动时保持可见，数据条目显示机体头像。

**仓库不包含游戏3D资源、DDS贴图、客户端或个人匹配结果。** 分享包包含工具源码和已抓取的Wiki结构化参考数据。没有本地模型时也能打开页面浏览参考条目，但不能做三维预览或保存模型匹配。

## 安装与启动

需要Python 3.10及以上和支持WebGL的现代浏览器。Windows推荐Python 3.11/3.12。无需管理员权限、Node.js或游戏服务器。

```powershell
git clone https://github.com/CharJtx/gundam-model-matcher.git
cd gundam-model-matcher
python -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe app.py --assets "D:\your-decrypted-assets" --open
```

也可双击`start.cmd`。默认读取仓库内`assets/`，或配置环境变量：

```powershell
$env:GUNDAM_ASSETS = 'D:\your-decrypted-assets'
.\start.cmd
```

资源目录应保持原始相对路径，例如：

```text
your-decrypted-assets/
└─ chara/
   └─ 01/01/0101/
      ├─ model/MSM_0101_0101_01.dxg
      └─ tex/MST_0101_0101_01C.dds
```

`--assets`指向包含`chara/`的父目录，不是单个模型文件。也可以把自己准备的资源放在本仓库`assets/chara/...`下；该目录已被Git忽略。不要把资源提交到仓库。

工具默认地址：http://127.0.0.1:8765 ，仅监听本机。关闭控制台停止服务。端口冲突可指定`--port 8767`。

macOS/Linux可使用`python3 -m venv .venv`、`.venv/bin/python -m pip install -r requirements.txt`和`.venv/bin/python app.py --assets /path/to/assets --open`；这两个系统尚未实际验证。

## 如何匹配

1. 左侧选择模型，可搜索资源编号和已匹配名称。
2. 中间拖动旋转，滚轮缩放，右键平移。默认会尝试选择基础颜色贴图、隐藏部分替换手型/贴花/光束；请人工检查，必要时在右侧调整。
3. 右侧搜索机体名称，通过头像和数据核对后勾选对应条目。允许一个模型关联多个数据条目，用于共用模型的不同版本或变体。
4. 展开“性能与武器”查看参考数值，填写备注，点击右上“保存匹配”。改动未保存时，切换模型会提醒。
5. 匹配结果写入`output/model_matches.json`，重启后保留；顶部可以导出JSON。分享自己标注的结果时只分享该文件即可。

图片以原Wiki链接按需加载，需要联网，未下载图片文件。已找到565/632个条目的头像；缺失或加载失败会明确显示。Three.js已本地附带，模型预览和已保存匹配本身不依赖CDN。

## 附带数据

| 文件 | 内容 |
|---|---|
| `data/wiki/units.json` | 632个Wiki页面、机体属性、5750条模板武器、4908个旧式表格，保留来源URL、修订号等 |
| `data/wiki/unit_images.json` | 565个条目的图片链接及缺失列表 |

原始抓取报告含27个页面失败，部分页面缺少属性或仍是未归一化表格。**不等于完整、统一或当前客户端版本的官方数据库。** Wiki序号不是游戏机型ID。

匹配结果保留模型相对路径与SHA256、模型ID、人工选择的Wiki标题/修订号/来源、逐网格贴图、显隐、UV方向、备注及更新时间。后续程序可据此生成自己的机型配置；工具不会自动把Wiki序号当作游戏ID，也不直接写入任何游戏服务器。

## 更新参考数据

正常使用不需要重新爬取。需要时：

```powershell
.venv\Scripts\python.exe crawl_gundam_wiki.py --out data/wiki
.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.venv\Scripts\python.exe fetch_unit_images.py
```

爬虫使用公开MediaWiki API并缓存响应，API可能返回HTTP567等错误；抓取结果会记录失败，图片补抓会保留已有链接。更新前可备份`data/wiki/`，并留意条目修订发生变化。运行工具不会自动爬取。

## 格式支持与限制

- 支持DXG 1.8静态网格流`0xFF01/0xFF02`，独立位置/法线/UV索引和多个分组。
- 显示原始静态姿态，不包含动画、完整游戏shader和所有隐藏部件规则。
- 贴图默认选择仅是建议，可手动修正并保存。
- 开发时在外部资源集识别659个模型，649个通过解析检查，10个失败；这不是649个模型都经过人工外观确认。不同资源版本可能存在额外不支持格式。
- 外部资源版本和运行客户端可能不同，匹配成功不代表该资源一定能在另一版本游戏中使用。

## 开发验证

```powershell
python -m py_compile app.py dxg.py fetch_unit_images.py crawl_gundam_wiki.py
python -m unittest discover -p "test_*.py" -v
```

未提供游戏资源时，两项真实模型测试会明确跳过，持久化测试仍运行。设置`GUNDAM_ASSETS`后可执行真实吉姆解析和资源目录测试。开发使用的模型始终位于仓库外，不作为测试附件提交。

## 来源与第三方组件

参考数据来源：[BWIKI敢达OL机体对比工具](https://wiki.biligame.com/gundam/敢达OL机体对比工具)及其链接机体页面。图片来自BWIKI原站，权利归相应权利人；本项目不对第三方数据或图片重新授予许可。请保留来源、修订信息，使用时遵守原站条款。

Three.js与OrbitControls：0.170.0，MIT许可证见`web/vendor/LICENSE`。工具代码的许可与第三方内容区分，见`LICENSE`。本项目不是官方工具，与游戏或Wiki运营方无隶属关系。
