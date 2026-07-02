global with sharing class ORDMDMScript {


    public static void syncGlobalProduct(){
        List<Object> GCVGlobalProducts = callAPiToGetCvDatas('NS-GlobalProductCode-en-Code',null,null);
        Map<String,Object> GCVGlobalPlatformsMap = callAPiToGetCvDatasMap('NS-GlobalPlatforms-en_NS-GlobalProductCode-en-Code_Normalised',null,null,'Id');
        Map<String,Object> GlbLoSL1sMap = callAPiToGetCvDatasMap('NS-GlbLoSL1-en_NS-GlobalProductCode-en-Group-SubGroup-Code_Normalised',null,null,'Id');
        Map<String,Object> eachRecordMap;
        Map<String,Map<String,Object>> allRecordMap = new Map<String,Map<String,Object>>();
        for(Object item:GCVGlobalProducts){
          eachRecordMap =  (Map<String,Object>)item;
          if(null != eachRecordMap.get('Id')){
              allRecordMap.put((String)eachRecordMap.get('Id'),eachRecordMap);
          }
        }
        List<GlobalProduct__c> insertProducts = new List<GlobalProduct__c>();
        GlobalProduct__c inertProduct;
        for(Object item:GCVGlobalProducts){
            Map<String,Object> mapItem = (Map<String,Object>)item;
            inertProduct = new GlobalProduct__c();
            inertProduct = buildGlobalProdut2(mapItem,inertProduct,GCVGlobalPlatformsMap,GlbLoSL1sMap);
            insertProducts.add(inertProduct);
        }
        List<GlobalProduct__c> deleteList = [select id from GlobalProduct__c];
        if(null != deleteList && !deleteList.isEmpty()){
            delete deleteList;
        }
        insert insertProducts;
    }

    private static GlobalProduct__c buildGlobalProdut2(Map<String,Object> globalRecord,GlobalProduct__c product2,Map<String,Object> GCVGlobalPlatformsMap,Map<String,Object> GlbLoSL1sMap){
        if(null == product2){
            product2 = new GlobalProduct__c();
        }
        //直接映射数据设置 比较简单
        String recordId = getStringValueFromRecord('Id',globalRecord);
        product2.Ext_ID__c = recordId;
        product2.ProductCode__c = getStringValueFromRecord('GlobalProductCode',globalRecord);
        product2.Name = getStringValueFromRecord('ProductCodeName',globalRecord);
        product2.Description__c = getStringValueFromRecord('Definition',globalRecord);
        product2.Product_Example_of_Services__c = getStringValueFromRecord('ProductCodeExampleServices',globalRecord);
        product2.Global_Code__c = true;
        product2.Territory__c = 'Global';
        if(globalRecord.containsKey('ActiveStatus') || null != globalRecord.get('ActiveStatus') || 'active' == (String)globalRecord.get('ActiveStatus')){
            product2.Closed__c = false;
            product2.isActive__c = true;
        }else{
            product2.Closed__c = true;
            product2.isActive__c = false;
        }
        product2.Effective_Date__c = StringToDate(getStringValueFromRecord('EffectiveDate',globalRecord));
        product2.Expiration_Date__c = StringToDate(getStringValueFromRecord('ExpiryDate',globalRecord));
        product2.SF_RecordTypeId__c = '012C800000023x4IAA';
        product2.SF_Owner__c = '005C8000000QwErIAK';

        //层级结构数据设置

        //GlobalPlatforms层级数据
        Map<Integer,Map<String,Object>> GCVGlobalPlatformsHerarchyRecordsMap = getHierarchyRecordMap(recordId,GCVGlobalPlatformsMap);
        product2.Global_Platforms__c = null != GCVGlobalPlatformsHerarchyRecordsMap.get(1)?getStringValueFromRecord('Id',GCVGlobalPlatformsHerarchyRecordsMap.get(1)):null;
        
        //GlobalLos层级数据
        Map<Integer,Map<String,Object>> GlbLoSL1sHerarchyRecordsMap = getHierarchyRecordMap(recordId,GlbLoSL1sMap);
        product2.Line_of_Service__c = null != GlbLoSL1sHerarchyRecordsMap.get(1)?getStringValueFromRecord('Id',GlbLoSL1sHerarchyRecordsMap.get(1)):null;
        product2.Product_Group_Name__c = null != GlbLoSL1sHerarchyRecordsMap.get(1)?getStringValueFromRecord('ProductCodeName',GlbLoSL1sHerarchyRecordsMap.get(2)):null;
        product2.Product_Sub_Group_Name__c = null != GlbLoSL1sHerarchyRecordsMap.get(1)?getStringValueFromRecord('Descriptor',GlbLoSL1sHerarchyRecordsMap.get(3)):null;

        return product2;
    }

    public static void setGroupName(){
        // Set<String> ids = new Set<String>();
        // String attributes1 = '-Local_Product_NK,-PwC_Network_UID,-PwC_Network_Descriptor,-Local_Product_Code,-Local_Product_Name,-Product_Record_Type,-Global_Product_UID,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        // Map<String,Map<String,Object>> localProducMap = callAPiToGetCvDatasMap(LOCAL_PRODUCT_CVNAME1,null,attributes1,'Universal_Local_Product_Code');
        // System.debug('数据1------------>: '+localProducMap.size());
        // String attributes2 = '-LocalProductPwCNetworkNodeId,-LocalProductPwCNetworkDescriptor,-LocalProductCode,-LocalProductName,-LastModifiedDate,-URI';
        List<Object> CustomAttributes = callAPiToGetCvDatas('ORD-LocalProductCustomAttributes',null,null);
        System.debug('数据2------------>: '+CustomAttributes.size());
        if(null == CustomAttributes || CustomAttributes.isEmpty()){
            return;
        }
        List<LocalProductCustomAttribute__c> insertList = new List<LocalProductCustomAttribute__c>();
        LocalProductCustomAttribute__c insertOne;
        Map<String,Object> itemMap;
        for(Object item:CustomAttributes){
            insertOne = new LocalProductCustomAttribute__c();
            itemMap = (Map<String,Object>)item;
            insertOne.LocalProductId__c = getStringValueFromRecord('LocalProductId', itemMap);
            insertOne.LocalProductCode__c = getStringValueFromRecord('LocalProductCode', itemMap);
            insertOne.LocalProductName__c = getStringValueFromRecord('LocalProductName', itemMap);
            insertOne.LocalProductPwCNetworkDescriptor__c = getStringValueFromRecord('LocalProductPwCNetworkDescriptor', itemMap);
            insertOne.LocalProductPwCNetworkNodeId__c = getStringValueFromRecord('LocalProductPwCNetworkNodeId', itemMap);
            insertOne.xLoSReportingProductGroupName__c = getStringValueFromRecord('xLoSReportingProductSubGroupName', itemMap);
            insertOne.xLoSReportingProductSubGroupName__c = getStringValueFromRecord('xLoSReportingProductGroupName', itemMap);
            insertList.add(insertOne);
        }

        List<LocalProductCustomAttribute__c> list1= [select id from LocalProductCustomAttribute__c];
        if(null != list1 && !list1.isEmpty()){
            delete list1;
        }
        
        insert insertList;

    }

    public static void saveCluster(){
        Map<String,Object> newTspHierarchyMap = callAPiToGetCvDatasMap('NS-PwCNetworkNode-en-NewTSPHierarchy_Normalised',null,null,'Id');
        System.debug('success get resposce');
        List<Product_Cluster__c> insertList = new List<Product_Cluster__c>();
        Product_Cluster__c insertOne = null;
        for(Object item:newTspHierarchyMap.values()){
            Map<String,Object> itemMap = (Map<String,Object>)item;
            insertOne = new Product_Cluster__c();
            String territory = getStringValueFromRecord('Id',itemMap);
            insertOne.Territory__c = territory;
            insertOne.level2_id__c = setHierarchyField(territory,2,newTspHierarchyMap,'Id');
            insertList.add(insertOne);
        }
        List<Product_Cluster__c> deletedList = [select id from Product_Cluster__c];
        if(null != deletedList && !deletedList.isEmpty()){
            delete deletedList;
        }
        insert insertList;
    }

    //获取所有层级结构数据并标注是哪个层级 最顶层为1 依次往下2，3，4....
    public static Map<Integer,Map<String,Object>> getHierarchyRecordMap(String recordId,Map<String,Object> hierarchyRecords){
        Map<Integer,Map<String,Object>> hierarchyRecordMap = new Map<Integer,Map<String,Object>>();
        List<Object> hierarchyObjectList = new List<Object>();
        //获取这条product所有的层级树结构数据
        getHierarchyRecords(recordId,hierarchyRecords,hierarchyObjectList);
        if(!hierarchyObjectList.isEmpty()){
            Integer hierarchyNum = 1;
            for(Integer i=hierarchyObjectList.size() -1 ; i>=0 ; i--){
                hierarchyRecordMap.put(hierarchyNum,(Map<String,Object>)hierarchyObjectList.get(i));
                hierarchyNum++;
            }
        }
        return hierarchyRecordMap;
    }

    //获取所有层级结构数据
    public static void getHierarchyRecords(String recordId,Map<String,Object> hierarchyRecords,List<Object> hierarchyList){
        if(null == hierarchyList){
            hierarchyList = new List<Object>();
        }
        Object item = hierarchyRecords.get(recordId);
        if(null != item){
            hierarchyList.add(item);
            Map<String,Object> itemMap = (Map<String,Object>)item;
            if(null != itemMap.get('ParentId')){
                String parentId = getStringValueFromRecord('ParentId',itemMap);              
                getHierarchyRecords(parentId,hierarchyRecords,hierarchyList);
            }
        }
    }

    public static String setHierarchyField(String recordId,Integer hierarchy,Map<String,Object> recordsMap,String fieldName){
        if(null == recordsMap || recordsMap.isEmpty() || null == recordId || String.isBlank(recordId) || null == fieldName || String.isBlank(fieldName)){
            return null;
        }
        Map<Integer,Map<String,Object>> itemHierarchyMap = getHierarchyRecordMap(recordId,recordsMap);
        if(null != itemHierarchyMap && !itemHierarchyMap.isEmpty() && itemHierarchyMap.containsKey(hierarchy)){
            return getStringValueFromRecord(fieldName, itemHierarchyMap.get(hierarchy));
        }
        return null;
    }


    public static Map<String,Map<String,Object>> callAPiToGetCvDatasMap(String cvName,String dateStr,String attributes,String mapKey){
        Map<String,Map<String,Object>> recordMap = new Map<String,Map<String,Object>>();
        List<Object> objects = callAPiToGetCvDatas(cvName,dateStr,attributes);
        if(null != objects && !objects.isEmpty()){
            for(Object item:objects){
                Map<String,Object> record = (Map<String,Object>)item;
                if(null != record.get(mapKey)){
                    recordMap.put((String)record.get(mapKey), record);
                }
            }
        }        
        return recordMap;
    }

        //PROD
        public static String URI = 'https://api.pwc.com:443/GlobalCVService/GlobalCVService.svc/cv/';
        public static String API_KEY = 'l78e1160ae4605476c8d8ec59d7e76931a';
        public static String API_SECRET = '641ce0d2cf89430fb63b262a34b5b938';
        public static String AUTHORIZATION = 'Basic Q05faWZzX1NhbGVzZm9yY2Vfb25fQWxpQ2xvdWRfcDAwMTp3cl9DIVVuK2NsNDRyXzM2';
        public static String PROXY_AUTHORIZATION = 'Basic Q05faWZzX1NhbGVzZm9yY2Vfb25fQWxpQ2xvdWRfcDAwMTo5ODIxRUR0TDI4aUQ0TmlMZEY5Zw==';

    //call GCV接口获取不同CV name的数据
    public static List<Object> callAPiToGetCvDatas(String cvName,String dateStr,String attributes){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('GET');
        String requestUrl = URI;
        if(null != cvName && !String.isBlank(cvName)){
            requestUrl = requestUrl+cvName;
        }
        if(null != attributes && !String.isBlank(attributes)){
            requestUrl = requestUrl+'?attributes='+attributes;
        }
        if(null != dateStr && !String.isBlank(dateStr)){
            requestUrl = requestUrl+'?since='+dateStr;
        }
        request.setEndpoint(requestUrl);
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');

        //这里设置Header
        request.setHeader('apikey',API_KEY);
        request.setHeader('apikeysecret',API_SECRET);
        request.setHeader('Authorization',AUTHORIZATION);
        request.setHeader('Proxy-Authorization',PROXY_AUTHORIZATION);

        request.setTimeout(120000);

        response = http.send(request);
        List<Object> dataList = (List<Object>)JSON.deserializeUntyped(response.getBody());
        if(null != dataList && !dataList.isEmpty()){
            return dataList;
        }else{
           return null;
        }
    }

    //按照key获取object中的字符串value值
    public static String getStringValueFromRecord(String key,Map<String,Object> record){
        if(record.containsKey(key) && record.get(key) != null){
            return String.valueOf(record.get(key));
        }else {
            return '';
        }
    }

        //时间字符串转date
        public static Date StringToDate(String dateStr){
            Date date1 = null;
            if(null != dateStr && dateStr.length() >= 8){
                String str = dateStr.substring(0,4)+'-'+dateStr.substring(4,6)+'-'+dateStr.substring(6,8);
                date1 = Date.valueOf(str);
            }
            return date1;  
        }


        public static void syncLocalProducts(){
            List<LocalProduct__c> list1 = [select id from LocalProduct__c limit 1000];

            delete list1;

        }




        // public static void syncLocalProducts(String fieldName){
        //     if(null == fieldName || String.isBlank(fieldName)){
        //         return;
        //     }
        //     String attributes = '';
        //     List<Object> localProducts = new List<Object>();
        //     if(fieldName.equals('Ext_ID__c')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Local_Product_Code,-Local_Product_Name,-Global_Product_UID,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         localProducts = callAPiToGetCvDatas('ORD-LocalProduct',null,attributes);
        //         if(null != localProducts && !localProducts.isEmpty()){
        //             LocalProduct__c localPriduct = null;
        //             for(Object item:localProducts){
        //                 Map<String,Object> record = (Map<String,Object>)item;
        //                 String recordType = getStringValueFromRecord('Product_Record_Type',record);
        //                 String territory = getStringValueFromRecord('PwC_Network_UID',record);
        //                 List<String> ignoreUpdateTerritorys = new List<String>(){'12760327','18635473','18635475',''};
        //                 if(String.isBlank(recordType) || recordType.equals('Product Group') || String.isBlank(territory) ){

        //                 }
        //                 String extId = getStringValueFromRecord('Universal_Local__Product_Code',record);
        //                 List<Object> selectProducts = [select id from LocalProduct__c where Ext_ID__c = :extId];
        //                 if(null != selectProducts || !selectProducts.isEmpty()){
        //                     localPriduct = (LocalProduct__c)selectProducts.get(0);
        //                 }                          
        //                 if(null == localPriduct){
        //                     localPriduct = new LocalProduct__c();
        //                     localPriduct.Ext_ID__c = extId;
        //                 }
        //                 localPriduct
        //             }
        //         }
        //     }
        // }

        
        // public static void syncLocalProducts(String fieldName,List<LocalProduct__c> LocalProducts){
        //     if(null == fieldName || String.isBlank(fieldName)){
        //         return;
        //     }
        //     String attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Global_Product_UID,-Local_Product_Code,-Local_Product_Name,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //     if(fieldName.equals('Name')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Global_Product_UID,-Local_Product_Code,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.Name = getStringValueFromRecord('Local_Product_Name',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('ProductCode')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Global_Product_UID,-Local_Product_Name,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.ProductCode__c = getStringValueFromRecord('Local_Product_Code',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('Description')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Global_Product_UID,-Local_Product_Name,-Local_Product_Code,-Global_Product_Code,-Global_Product_Descriptor,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.Description__c = getStringValueFromRecord('Product_Description',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('Product Example of service')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Global_Product_UID,-Local_Product_Name,-Local_Product_Code,-Global_Product_Code,-Global_Product_Descriptor,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI,-Product_Description';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.Product_Example_of_service__c = getStringValueFromRecord('Example_of_Services',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('territory')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-Global_Product_UID,-Local_Product_Code,-Local_Product_Name,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.territory__c = getStringValueFromRecord('PwC_Network_UID',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('Global Product UID')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Local_Product_Code,-Local_Product_Name,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.Global_Product_UID__c = getStringValueFromRecord('Global_Product_UID',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }else if(fieldName.equals('Local Product Name')){
        //         attributes = '-Local_Product_SK,-Local_Product_NK,-PwC_Network_Descriptor,-Product_Record_Type,-PwC_Network_UID,-Local_Product_Code,-Local_Product_Name,-Global_Product_Code,-Global_Product_Descriptor,-Product_Description,-Example_of_Services,-Record_Status,-Effective_Date,-Expiration_Date,-Comments,-Created_Datetime,-Last_Modified_Datetime,-URI';
        //         Map<String,Object> LocalProductMap = callAPiToGetCvDatasMap('ORD-LocalProduct',null,attributes,'Universal_Local__Product_Code');
        //         for(LocalProduct__c item:LocalProducts){
        //             String extId = item.Ext_ID__c;
        //             if(LocalProductMap.containsKey(extId)){
        //                 item.Global_Product_UID__c = getStringValueFromRecord('Global_Product_UID',(Map<String,Object>)LocalProductMap.get(extId));
        //             }
        //         }
        //         update LocalProducts;
        //     }
        // }
            
}