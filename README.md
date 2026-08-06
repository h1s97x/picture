# picture

图云

一个用于存放和管理图片的图床项目。

## 图片命名规范

> ⚠️ 上传新图片前，请先阅读 [NORMALIZING.md](NORMALIZING.md)，命名不规范的图片会被 CI 拒绝。

**一句话规则：`<语义名>-<日期YYYYMMDD>.<扩展名>`**（全小写、英文、`-` 分隔、日期在末尾）。

```text
✅ mushoku-tensei-20260302.webp   yuki-20260302.jpg
❌ 20260302-Mushoku-Tensei.webp   yuki.jpg   %E5%8D%A1...png   图片.png
```

## 目录结构

```
├── images/              # 唯一图片资源目录
│   ├── <新图>           # PicList 上传的新图，直接平铺（遵循命名规范）
│   └── _legacy/         # 历史 Doc/ 归档图片（856 张，只读不动）
├── scripts/             # 工具脚本（validate-images.sh 命名校验）
├── NORMALIZING.md       # 图片命名规范（新图必读）
├── LICENSE              # MIT 许可证
└── README.md            # 项目说明
```

> 图片地址统一使用：`https://cnb.cool/h1s97x/Pixy/-/raw/main/images/<文件名>`
> 历史图片在 `images/_legacy/` 下归档，旧链接仍可通过历史提交访问，不会 404。

## 本地校验

```bash
scripts/validate-images.sh            # 校验仓库内所有图片（不含 _legacy）
scripts/validate-images.sh <文件>     # 上传前自检指定图片
```

## 许可证

本项目基于 [MIT License](LICENSE) 开源，详见 [LICENSE](LICENSE) 文件。
