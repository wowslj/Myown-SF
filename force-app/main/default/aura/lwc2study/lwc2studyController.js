({
    // 初始化执行
    init: function (component, event, helper) {
        let columns = [
            {label: 'OrderName', fieldName: 'OrderNameV'},
            {label: 'Price', fieldName: 'PriceV'},
            {label: 'OrderType', fieldName: 'OrderTypeV'},
            {label: 'ApprovalStatus', fieldName: 'ApprovalStatusV'},
        ]
        component.set('v.columns', columns);

        

        // component.get    获取变量  let data = component.get('v.变量名')
        // component.set    变量赋值  component.set('v.变量名',data)
        // component.find   获取节点  component.find('')

        // 调用后端返回数据
        // helper.fetchData(component)
        helper.getdata(component)
    },
    Search:function(component, event, helper){
        helper.getdata(component)
        // component.set('v.data',newdata)
    },
    Reset:function(component, event, helper){
        component.set('v.searchField',{})
        helper.getdata(component)
    }
    
    // TypehandleChange: function (component, event) {
    //     // This will contain the string of the "value" attribute of the selected option
    //     var selectedOptionValue = event.getParam("value");
    //     component.set('v.searchField.OrderType',selectedOptionValue)
       
    // },
    // ApprovalhandleChange: function (component, event) {
    //     // This will contain the string of the "value" attribute of the selected option
    //     var selectedOptionValue = event.getParam("value");
    //     component.set('v.searchField.ApprovalStatus',selectedOptionValue)
       
    // }
})