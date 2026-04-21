# Profile Scripts Group

目标承载 `init-01` 到 `init-04` 的脚本包装层。

范围：

- `project_profile` 初始化
- 阶段推进
- 阶段 reviewer
- 对应的人类确认关口

当前仍由上层通用脚本和 `artifact_utils.rb` 驱动，后续再迁入本组。

当前 wrapper：

- [init_project_profile_step.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/init/profile/init_project_profile_step.rb)
- [init_project_profile_review.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/init/profile/init_project_profile_review.rb)
- [render_project_profile_step.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/init/profile/render_project_profile_step.rb)
