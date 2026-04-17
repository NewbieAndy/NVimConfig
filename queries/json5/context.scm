; JSON5 context 查询 - 显示键路径与数组层级
;
; JSON5 节点结构与 JSON 不同：
;   member -> name: (string|identifier), value: (object|array|...)
;   array  -> 直接包含子元素
; （注意：JSON5 用 member/name，JSON 用 pair/key）

; 捕获键值对：显示 name: { 或 name: [
; @context.final 使上下文只显示 member 第一行（name 所在行）
(member
  name: (_) @context.final) @context

; 捕获数组节点：标识数组层级边界
(array) @context
