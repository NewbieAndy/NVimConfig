; JSON context 查询 - 显示键路径与数组层级
;
; 节点结构：
;   pair   -> key: (string), value: (object|array|...)
;   array  -> 直接包含子元素

; 捕获键值对：显示 "key": { 或 "key": [
; @context.final 标记 key 为最后一个需要展示的子节点，
; 使得上下文只显示 pair 的第一行（key 所在行）
(pair
  key: (string) @context.final) @context

; 捕获数组节点：
; - 当光标在无父级 pair 的根数组内时，显示 [ 标识所在层级
; - 配合 pair 上下文，在多层嵌套数组时提示数组边界
(array) @context
