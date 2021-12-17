# saber
> Standardization of address using Baidu natural language processing api easily in R.

`saber`包旨在R中利用百度智能云自然语言处理的接口，轻松实现地址标准化。`saber`包由` getAccesstoken`函数和`getAddress`函数组成。

## getAccesstoken

`getAccesstoken`函数用于获取access_token。由于百度智能云使用了鉴权机制，调用API时必须在URL中带上access_token参数。在百度智能云中创建应用后，获取应用的API Key和Secret Key，然后使用`getAccesstoken`函数获取access_token。



```R
access_token = getAccesstoken(api_key = "xxxxxxxx", secret_key = "xxxxxxxx")
```



## getAddress

`getAddress`函数用于将地址转换为标准地址。

函数的参数如下：

- data：数据框

- address：数据框中待标准化的地址变量名

- confidence：取值100-0，默认为100。该字段用于触发补充解析策略，对置信度在配置值以下的结果，进行补充解析，以提高结果精度。该字段配置会增加服务耗时。经评测，在保证准确率提升效果的前提下，当取值=50时，服务平响增长相对较小。也可根据业务数据评测，决定取值。

- retry：解析失败后重试次数。在网络状况不佳或服务器响应问题时，可能返回错误导致地址解析失败。设置retry参数后，可以对该地址尝试进行若干次的重新解析，直至返回正确结果或者达到最大尝试次数。默认尝试次数为3次。

  

返回data.table格式的结果，除了原始数据的变量外，还包括：

- `original_address`：数据框中待标准化的地址

- `formatted_address`：标准化地址

- `lng`：经度

- `lat`：纬度

- `province`：省（直辖市/自治区）

- `city`：市

- `county`：区（县）

-  `town`：街道（乡/镇）

-  `detail`：详细地址

-  `province_code`：省国标code

- `city_code`：城市国标code

- `county_code`：区县国标code

- `town_code`：街道/乡镇国标code

  

```R
results <- getAddress(data = df, address = "addr")
```

