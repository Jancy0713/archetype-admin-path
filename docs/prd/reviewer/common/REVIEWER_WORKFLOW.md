# Reviewer Workflow

## reviewer 身份要求

1. reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行。
2. 主产物生成 agent 不得自己兼任 reviewer。
3. 如果 reviewer 发现自己就是主产物生成者，应停止并要求切换上下文。

## reviewer 任务边界

1. 只审查，不重写正文。
2. 优先识别阻塞推进的 P0。
3. 不擅自补全关键业务事实。
4. 不把“建议优化”伪装成 blocking issue。

## reviewer 输出要求

必须显式填写：

1. `findings.issues`
2. `findings.missing_info`
3. `findings.p0`
4. `decision.has_blocking_issue`
5. `decision.allow_next_step`
6. `decision.need_human_escalation`
7. `required_revisions`

## 返工约定

1. 主 agent 只能根据 reviewer 结果返工，不得跳过 review 直接进入下一步。
2. 超过 retry 上限后，如果仍有 blocking issue，必须升级给人。
