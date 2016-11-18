<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<script type="text/javascript" src="/js/jquery.min.js"></script>
<style>
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}

.auto_hidden {
	width: 204px;
	border-top: 1px solid #333;
	border-bottom: 1px solid #333;
	border-left: 1px solid #333;
	border-right: 1px solid #333;
	position: absolute;
	display: none;
}

.auto_show {
	width: 204px;
	border-top: 1px solid #333;
	border-bottom: 1px solid #333;
	border-left: 1px solid #333;
	border-right: 1px solid #333;
	position: absolute;
	z-index: 9999; /* 设置对象的层叠顺序 */
	display: block;
}

.auto_onmouseover {
	color: #ffffff;
	background-color: highlight;
	width: 100%;
}

.auto_onmouseout {
	color: #000000;
	width: 100%;
	background-color: #ffffff;
}

.font_01 {
	color: #FF0000;
}
</style>
<script language="javascript">
	var $$ = function(id) {
		return "string" == typeof id ? document.getElementById(id) : id;
	}
	var Bind = function(object, fun) {
		return function() {
			return fun.apply(object, arguments);
		}
	}
	var arrayObj = new Array();
	$(function() {
		$.get("/Query?topicName=小凡", function(data) {
			for (var i = 0; i < data.length; i++) {
				console.log(data[i].content);
				arrayObj.push(data[i].content)
			}
		});
	})
	function AutoComplete(obj, autoObj) {
		this.obj = $$(obj); //输入框
		this.autoObj = $$(autoObj);//DIV的根节点
		this.value_arr = arrayObj; //不要包含重复值
		this.index = -1; //当前选中的DIV的索引
		this.search_value = ""; //保存当前搜索的字符
	}
	AutoComplete.prototype = {
		//初始化DIV的位置
		init : function() {
			this.autoObj.style.left = this.obj.offsetLeft + "px";
			this.autoObj.style.top = this.obj.offsetTop + this.obj.offsetHeight
					+ "px";
			this.autoObj.style.width = this.obj.offsetWidth - 2 + "px";//减去边框的长度2px
		},
		//删除自动完成需要的所有DIV
		deleteDIV : function() {
			while (this.autoObj.hasChildNodes()) {
				this.autoObj.removeChild(this.autoObj.firstChild);
			}
			this.autoObj.className = "auto_hidden";
		},
		//设置值
		setValue : function(_this) {
			return function() {
				_this.obj.value = this.seq;
				_this.autoObj.className = "auto_hidden";
			}
		},
		//模拟鼠标移动至DIV时，DIV高亮
		autoOnmouseover : function(_this, _div_index) {
			return function() {
				_this.index = _div_index;
				var length = _this.autoObj.children.length;
				for (var j = 0; j < length; j++) {
					if (j != _this.index) {
						_this.autoObj.childNodes[j].className = 'auto_onmouseout';
					} else {
						_this.autoObj.childNodes[j].className = 'auto_onmouseover';
					}
				}
			}
		},
		//更改classname
		changeClassname : function(length) {
			for (var i = 0; i < length; i++) {
				if (i != this.index) {
					this.autoObj.childNodes[i].className = 'auto_onmouseout';
				} else {
					this.autoObj.childNodes[i].className = 'auto_onmouseover';
					this.obj.value = this.autoObj.childNodes[i].seq;
				}
			}
		},
		//响应键盘
		pressKey : function(event) {
			var length = this.autoObj.children.length;
			//光标键"↓"
			if (event.keyCode == 40) {
				++this.index;
				if (this.index > length) {
					this.index = 0;
				} else if (this.index == length) {
					this.obj.value = this.search_value;
				}
				this.changeClassname(length);
			}
			//光标键"↑"
			else if (event.keyCode == 38) {
				this.index--;
				if (this.index < -1) {
					this.index = length - 1;
				} else if (this.index == -1) {
					this.obj.value = this.search_value;
				}
				this.changeClassname(length);
			}
			//回车键
			else if (event.keyCode == 13) {
				this.autoObj.className = "auto_hidden";
				this.index = -1;
			} else {
				this.index = -1;
			}
		},
		//程序入口
		start : function(event) {
			if (event.keyCode != 13 && event.keyCode != 38
					&& event.keyCode != 40) {
				this.init();
				this.deleteDIV();
				this.search_value = this.obj.value;
				var valueArr = this.value_arr;
				valueArr.sort();
				if (this.obj.value.replace(/(^\s*)|(\s*$)/g, '') == "") {
					return;
				}//值为空，退出
				try {
					var reg = new RegExp("(" + this.obj.value + ")", "i");
				} catch (e) {
					return;
				}
				var div_index = 0;//记录创建的DIV的索引
				for (var i = 0; i < valueArr.length; i++) {
					if (reg.test(valueArr[i])) {
						var div = document.createElement("div");
						div.className = "auto_onmouseout";
						div.seq = valueArr[i];
						div.onclick = this.setValue(this);
						div.onmouseover = this.autoOnmouseover(this, div_index);
						div.innerHTML = valueArr[i].replace(reg,
								"<strong class='font_01'>$1</strong>");//搜索到的字符粗体显示
						this.autoObj.appendChild(div);
						this.autoObj.className = "auto_show";
						div_index++;
					}
				}
			}
			this.pressKey(event);
			window.onresize = Bind(this, function() {
				this.init();
			});
		}
	}
</script>
<body>

	<div align="center" style="padding-top: 50px">
		<input type="text"
			style="width: 400px; height: 20px; font-size: 14pt;"
			placeholder="请输入关键字" id="o" onkeyup="autoComplete.start(event)">
	</div>
	<div class="auto_hidden" id="auto">
		<!--自动完成 DIV-->
	</div>
	<script type="text/javascript">
		var autoComplete = new AutoComplete('o', 'auto');
	</script>
</body>
</html>