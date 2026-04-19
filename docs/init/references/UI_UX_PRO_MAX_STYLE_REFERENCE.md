# UI/UX Pro Max 风格参考

来源：本地已安装 skill `ui-ux-pro-max`

- skill 路径：`/Users/wangwenjie/.agents/skills/ui-ux-pro-max`
- 主要数据源：
  - `data/products.csv`
  - `data/styles.csv`

本文件不是自造风格库，而是从 `UI/UX Pro Max` 中提取出更适合初始化流程里 `experience_platform.ui_style_recipe` 使用的候选范围，方便主模型在问答时直接复用。

## 使用约束

1. `ui_style_recipe` 的候选项优先引用下面的原始风格名，不要另起一套名字。
2. 推荐时先匹配产品类型，再组合 1 个主风格和 1-2 个辅助风格。
3. 候选项控制在 3-5 个，不要把整份 style 库一次性丢给用户。
4. 用户可以自定义组合，但默认推荐项应尽量直接来自下方映射。
5. 如果没有现成截图或模板，不要伪造视觉预览；改为给“风格预览描述”，说明布局、色彩、层次、圆角、阴影、动效倾向。

## 适合本流程的核心风格

### 1. Minimalism & Swiss Style

- 来源：`styles.csv`
- 关键词：Clean, simple, spacious, functional, high contrast, geometric, grid-based
- 适合：Enterprise apps, dashboards, documentation sites, SaaS platforms, professional tools
- 不适合：Playful / artistic / entertainment-heavy 场景
- 预览描述：大留白、清晰网格、弱装饰、强信息层级、几乎不依赖特效

### 2. Flat Design

- 来源：`products.csv` 中多类后台工具推荐
- 适合：CRM、Inventory、Email Client、Productivity Tool、Knowledge Base 等管理与工具型产品
- 预览描述：层次清晰、边界明确、实现稳、组件语义清楚，适合作为后台主基调

### 3. Glassmorphism

- 来源：`styles.csv`
- 关键词：Frosted glass, transparent, blurred background, layered, vibrant background
- 适合：Modern SaaS, financial dashboards, modal overlays, navigation
- 风险：对比度和性能要额外控制
- 预览描述：半透明卡片、模糊背景、轻层叠、视觉更“现代 SaaS”，适合做局部强调，不宜全站滥用

### 4. Data-Dense + Heat Map & Heatmap

- 来源：`products.csv` 中 `Analytics Dashboard`
- 适合：Analytics / admin / data / panel
- 预览描述：卡片密度高、指标优先、图表和筛选器占比较高、强调比较和状态色

### 5. AI-Native UI

- 来源：`products.csv` 中 `AI/Chatbot Platform`
- 适合：AI platform, automation, machine-learning, conversational interface
- 预览描述：更强调生成过程、任务流、流式反馈、结果区与参数区分层，适合作为 AI 产品特征叠加

### 6. Bento Box Grid

- 来源：`styles.csv`
- 关键词：Modular cards, asymmetric grid, dashboard tiles, clean hierarchy
- 适合：Dashboards, product pages, SaaS
- 预览描述：模块化卡片、大小错落、较强“看板感”，适合首页概览和工作台

### 7. Dark Mode (OLED)

- 来源：`products.csv` 多个 dashboard/AI/monitoring 类型推荐
- 适合：监控、沉浸式工作区、创作类工具区
- 风险：不适合默认用于普通商家后台日常办公；更适合作为可切换主题或局部工作区
- 预览描述：深色背景、高亮状态色、沉浸感更强，但要求更严格的对比和语义色控制

### 8. Accessible & Ethical

- 来源：`products.csv`
- 作用：不是独立视觉风格，更像约束层
- 适合：Government/Public Service、Design System、高可读后台
- 预览描述：对比稳定、状态表达保守、可访问性优先，适合作为后台风格的底层规则

## 产品类型到风格的直接映射

以下映射直接提取或收敛自 `products.csv`：

### SaaS (General)

- 主推荐：Glassmorphism + Flat Design
- 次推荐：Soft UI Evolution, Minimalism
- 后台倾向：Data-Dense + Real-Time Monitoring
- 适用说明：更现代，但落地时要控制玻璃效果比例

### Analytics Dashboard

- 主推荐：Data-Dense + Heat Map & Heatmap
- 次推荐：Minimalism, Dark Mode (OLED)
- 后台倾向：Drill-Down Analytics + Comparative
- 适用说明：如果系统强依赖数据看板、任务状态、模型效果对比，这组很合适

### AI/Chatbot Platform

- 主推荐：AI-Native UI + Minimalism
- 次推荐：Zero Interface, Glassmorphism
- 后台倾向：AI/ML Analytics Dashboard
- 适用说明：适合把“生成中 / 生成结果 / 参数配置 / 历史记录”做成 AI 产品感更强的工作台

### Productivity Tool

- 主推荐：Flat Design + Micro-interactions
- 次推荐：Minimalism, Soft UI Evolution
- 后台倾向：Drill-Down Analytics
- 适用说明：适合操作频繁、表单列表多、任务流明确的工具后台

## 对“商家端 AI 视频生成系统”的推荐收敛

结合本项目“商家端 + AI 视频生成 + SaaS + PC Web 后台”，推荐优先级建议如下：

1. `Flat Design + Minimalism + AI-Native UI`
2. `Data-Dense + Heat Map & Heatmap + Minimalism`
3. `Glassmorphism + Flat Design`
4. `Bento Box Grid + Flat Design`

推荐理由：

- 商家后台本质上仍是工具型和管理型系统，主基调应该先稳，不应先追求重装饰。
- 这是 AI 视频生成系统，需要保留 AI 工作台特征，所以可叠加 `AI-Native UI`，但不宜把整站做成聊天产品。
- 如果首页或运营页有大量任务、生成记录、额度、成功率、素材状态，`Data-Dense` 很适合作为仪表板层。
- `Glassmorphism` 可以做辅助特征，但不建议作为后台全站主基调。

## 风格预览描述模板

当没有现成视觉模板时，`ui_style_recipe.options[].description` 建议至少描述：

1. 页面气质：专业 / 现代 / 数据优先 / AI 工作台
2. 布局结构：首页是否偏卡片工作台、列表工作台、指标看板
3. 色彩倾向：中性浅底、深色工作区、蓝橙对比、状态色策略
4. 组件特征：圆角大小、阴影强弱、是否允许毛玻璃
5. 动效倾向：是否只保留 150-300ms 的轻反馈

示例：

- `Flat Design + Minimalism + AI-Native UI`
  预览描述：浅色主界面，规整卡片和表格为主，参数配置区与结果区明确分栏，按钮和状态标签语义清晰，只保留轻量过渡动效，整体更像专业 AI 工作台而不是营销站。
- `Data-Dense + Heat Map & Heatmap + Minimalism`
  预览描述：首页以指标卡、任务趋势、成功率分布和异常提示为主，颜色主要服务于状态表达，图表和筛选器比重更高，适合高频运营和批量管理场景。
- `Glassmorphism + Flat Design`
  预览描述：整体仍以清晰后台结构为主，但在顶部概览卡、弹窗和局部工作区加入轻毛玻璃和层叠阴影，观感更现代，但不会牺牲可读性。
