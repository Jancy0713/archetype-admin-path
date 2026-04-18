# PRD 参考资料索引

这个目录用于保存“拆解 PRD”阶段可复用的外部参考资料、阅读摘要和本地整理结果。

当前原则：

- 不直接镜像第三方完整内容
- 优先保留来源链接、阅读摘要、关键方法和对本项目的启发
- 和当前工作流强相关的内容，沉淀为我们自己的规则或模板

## 当前参考

### 1. Harness 实战（本地 OCR 整理）

- 文件：
  - [Harness实战(PM极度舒适版).md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/Harness实战(PM极度舒适版).md)
  - [image.png](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/image.png)
  - [image-1.png](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/image-1.png)
- 说明：
  - 来源于小红书文章
  - 当前仓库保存的是 OCR 整理版，内容可能有识别误差
- 重点价值：
  - `Debate` 机制：把高质量 PRD 讨论流程化
  - `Conductor` 机制：把需求落地做成带审查和升级协议的流水线

### 2. Claude Code PM Course

- 来源：
  - [carlvellotti/claude-code-pm-course](https://github.com/carlvellotti/claude-code-pm-course)
- 本地摘要：
  - [claude-code-pm-course.notes.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/claude-code-pm-course.notes.md)
- 重点价值：
  - 面向 PM 的交互式课程
  - 明确强调 Claude Code 是思考伙伴，不只是自动化工具
  - 包含 PRD、代理协作、项目记忆等内容

### 3. gstack

- 来源：
  - [garrytan/gstack](https://github.com/garrytan/gstack)
  - [gstack 官网](https://gstack.lol/)
- 本地摘要：
  - [gstack.notes.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/gstack.notes.md)
- 重点价值：
  - 强调 ordered workflow，而不是 blank prompt
  - `/office-hours` 对我们“需求补充提问”阶段很有参考价值
  - 重视 plan/review/qa/ship 的有序继承

### 4. CCPM

- 来源：
  - [automazeio/ccpm](https://github.com/automazeio/ccpm)
- 本地摘要：
  - [ccpm.notes.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/ccpm.notes.md)
- 重点价值：
  - PRD -> Epic -> Task -> Issue -> Code 的链路很完整
  - 明确提出 guided brainstorming
  - 很适合参考它的“先提问、再成文、再拆解”节奏

## 对我们当前最有帮助的结论

在“拆解 PRD”这个步骤里，当前最值得直接借鉴的是：

1. 不要让需求一上来就进入实现
2. AI 必须先做补充提问
3. 提问不是随便追问，而是分层推进
4. 提问完成后再进入结构化 PRD
5. 结构化结果应继续进入 contract，而不是停留在自然语言文档
