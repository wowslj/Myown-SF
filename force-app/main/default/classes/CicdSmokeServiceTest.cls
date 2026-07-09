@IsTest
private class CicdSmokeServiceTest {
    @IsTest
    static void checkInputReturnsSuccessForValidText() {
        Test.startTest();
        CicdSmokeService.Result result = CicdSmokeService.checkInput('CICD Test');
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('Input accepted.', result.message);
        System.assertEquals(9, result.score);
    }

    @IsTest
    static void checkInputReturnsFailureForBlankText() {
        Test.startTest();
        CicdSmokeService.Result result = CicdSmokeService.checkInput('   ');
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('Input is required.', result.message);
        System.assertEquals(0, result.score);
    }

    @IsTest
    static void addNumbersHandlesNormalValues() {
        Integer result = CicdSmokeService.addNumbers(10, 15);

        System.assertEquals(25, result);
    }

    @IsTest
    static void addNumbersHandlesNullValues() {
        Integer result = CicdSmokeService.addNumbers(null, 7);

        System.assertEquals(7, result);
    }
}
