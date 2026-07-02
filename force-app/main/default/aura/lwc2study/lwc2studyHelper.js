({
    fetchData: function (component) {
        
    let data =  [{
            "OrderNameV":"111",
            "PriceV":"1111",
            "OrderTypeV":"11111",
            "ApprovalStatusV":"111111"
        },{
            "OrderNameV":"222",
            "PriceV":"2222",
            "OrderTypeV":"22222",
            "ApprovalStatusV":"222222" 
        }]
        component.set('v.data',data)
    },


    getdata: function (component) {
        console.log(4444);

        // 绑定的apex文件的接口名字
        var action = component.get('c.OrderSerch');
        let searchField = component.get('v.searchField') 
        action.setParams({
            name:searchField.Name,
            type:searchField.OrderType,
            price:searchField.Price,
            approvalStatus:searchField.ApprovalStatus,
        });
        action.setCallback(this, function (response) {
            // 获取响应
            var state = response.getState();             // 响应状态,成功为SUCCESS
            console.log("state",JSON.stringify(state))

            if (state === 'SUCCESS' ) {
            	var result = response.getReturnValue();  // 响应成功的返回值
                console.log("result:",result)
                let OrderList=[]
                let resultJSON = JSON.parse(result)    
                console.log("resultJson:",resultJSON)  
                resultJSON.forEach(value => {
                    OrderList.push({
                        OrderNameV :     value.Name,
                        OrderTypeV :     value.Order_Type__c,
                        PriceV :         value.Price__c,
                        ApprovalStatusV :      value.Approval_Status__c
                    })
                });
                console.log("orderList",OrderList)
                component.set('v.data',OrderList)
                component.set('v.datacopy',OrderList)
                // 调用成功的处理
            }else{
                // 调用错误的处理
                // 官方的弹窗组件
               var toastEvt = $A.get("e.force:showToast");
               toastEvt.setParams({
                   "title": "Error",           // 弹窗的标题
                   "message": "错误的提示文字",
                   "type": "error"             // Error错误弹窗,Success为成功弹窗
               }).fire();
            }
        });
        $A.enqueueAction(action);
    }
    
})