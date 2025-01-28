# 頁面權限清單

## 訂單管理 (/orders)

### 訂單列表頁面 (/orders)
- 管理員(admin): 完全訪問權限,可查看所有訂單
- 司機(driver): 只能查看自己的訂單
- 調度員(dispatcher): 只能查看所有訂單,無法修改

### 新增訂單頁面 (/orders/new)
- 管理員(admin): 可以創建訂單
- 調度員(dispatcher): 可以創建訂單
- 司機(driver): 無權訪問

### 訂單詳情頁面 (/orders/:id)
- 管理員(admin): 可以查看所有訂單詳情
- 司機(driver): 只能查看自己的訂單詳情
- 調度員(dispatcher): 無權訪問

## 車輛管理 (/vehicles)

### 車輛列表頁面 (/vehicles)
- 管理員(admin): 完全訪問權限
- 司機(driver): 無權訪問
- 調度員(dispatcher): 無權訪問

### 新增車輛頁面 (/vehicles/new)
- 管理員(admin): 可以新增車輛
- 司機(driver): 無權訪問
- 調度員(dispatcher): 無權訪問

### 編輯車輛頁面 (/vehicles/:id/edit)
- 管理員(admin): 可以編輯車輛
- 司機(driver): 無權訪問
- 調度員(dispatcher): 無權訪問

## 司機管理 (/drivers)

### 司機列表頁面 (/drivers)
- 管理員(admin): 完全訪問權限
- 司機(driver): 無權訪問
- 調度員(dispatcher): 無權訪問

## 系統設置 (/settings)

### 設置頁面 (/settings)
- 管理員(admin): 完全訪問權限
- 司機(driver): 無權訪問
- 調度員(dispatcher): 無權訪問

## 用戶相關頁面

### 登入頁面 (/login)
- 所有用戶都可以訪問

### 註冊頁面 (/signup) 
- 所有用戶都可以訪問

### 未授權頁面 (/unauthorized)
- 所有用戶都可以訪問