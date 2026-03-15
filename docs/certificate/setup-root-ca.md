[[_TOC_]]

# 如何新增根憑證授權單位(root certificate authority)
## Windows 10使用者
1. 目前由IT管理的電腦僅能新增至登入時所使用的帳號下，且該帳號必需擁有系統管理者權限
2. 下載[根憑證](zooDeveloperPlatformRootCA.crt)至電腦內
3. 輸入win+r，開啟執行視窗，接著輸入certmgr.msc，按下enter
4. 在開啟的certmgr視窗中，找到`受信任的根憑證授權單位`並點選其左方的展開icon
5. 展開後會發現有`憑證`這個項目，請點擊後再按滑鼠右鍵 -> 滑鼠移到`所有工作` -> 點選`匯入`
6. 在開啟的`憑證匯入精靈`視窗中，會發現存放位置無法選擇(預設為`目前使用者`)，此時按`下一步`
7. 點選`瀏覽`，選取步驟2下載的根憑證檔案 -> 點選`下一步`
8. 點選`將所有憑證放入以下的存放區` -> 按下`瀏覽`以選擇憑證存放區 -> 選擇`受信任的根憑證授權單位` -> 點選`確定`
9. 按下`下一步` -> 按下`完成`
10. 在跳出的安全性警告視窗中，可看到匯入的憑證訊息，授權單位為`ZOO Developer Platform Root CA`，憑證指紋(sha1)為`XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX`
11. 請點選`是`以繼續，接著會出現`匯入執行成功`的訊息，點選`確定`
12. 選擇視窗上方的重新整理icon，可看到剛所匯入的根憑證(到期日為`20XX/XX/XX`)

## Ubuntu 22.04使用者
1. 請確認執行帳號擁有sudo權限
2. 下載[根憑證](zooDeveloperPlatformRootCA.crt)至電腦內
3. 將根憑證放到路徑`/usr/local/share/ca-certificates`之下
4. 執行`sudo update-ca-certificates --fresh`，此步驟會更新`/etc/ssl/certs`內的所有憑證，包含`ca-certificates.crt`ca bundle憑證
5. 確認`/etc/ssl/certs`路徑下有名為`zooDeveloperPlatformRootCA.pem`的檔案連結至step3的檔案

## Firefox使用者
Firefox並不會使用windows的憑證儲存區，所以必須額外設定。(Microsoft Edge及Chrome會使用作業系統的憑證儲存區，因此不需要再做其它設定)
1. 打開 Firefox，進入「設定」(Settings)→「隱私權與安全性」(Privacy & Security)。
2. 向下滾動到「憑證」(Certificates)區塊，然後點擊「檢視憑證」(View Certificates)。
3. 在「憑證機構」(Authorities)分頁下，點擊「匯入」(Import)。
4. 選擇所下載的根憑證檔案，並勾選「信任此 CA 來識別網站」(Trust this CA to identify websites)。
5. 點擊「確定」(OK)