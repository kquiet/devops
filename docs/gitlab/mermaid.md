**Gitlab可透過與kroki server的整合，支援在markdown檔案內容裏嵌入mermaid語法以顯示圖片。**

目前雖然不是支援所有的mermaid視覺化效果，但常用的diagram大部份都有支援(如流程圖、甘特圖、心智圖)。

詳細可參考mermaid的語法說明：https://mermaid.js.org/intro/syntax-reference.html

---

## 流程圖

```mermaid
flowchart TB
    A & B--> C & D
```
---

## 甘特圖

```mermaid
gantt
    title A Gantt Diagram
    dateFormat YYYY-MM-DD
    section Section
        A task          :a1, 2014-01-01, 30d
        Another task    :after a1, 20d
    section Another
        Task in Another :2014-01-12, 12d
        another task    :24d
```
---

## 心智圖

```mermaid
mindmap
  root((mindmap))
    Origins
      Long history
      ::icon(fa fa-book)
      Popularisation
        British popular psychology author Tony Buzan
    Research
      On effectiveness<br/>and features
      On Automatic creation
        Uses
            Creative techniques
            Strategic planning
            Argument mapping
    Tools
      Pen and paper
      Mermaid
```
---