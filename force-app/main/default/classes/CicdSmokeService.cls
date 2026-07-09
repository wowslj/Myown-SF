public without sharing class CicdSmokeService {
    public class Result {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Integer score;

        public Result(Boolean success, String message, Integer score) {
            this.success = success;
            this.message = message;
            this.score = score;
        }
    }

    public static Result checkInput(String inputText) {
        if (String.isBlank(inputText)) {
            return new Result(false, 'Input is required.', 0);
        }

        Integer score = inputText.trim().length();
        return new Result(true, 'Input accepted.', score);
    }

    public static Integer addNumbers(Integer a, Integer b) {
        Integer leftValue = a == null ? 0 : a;
        Integer rightValue = b == null ? 0 : b;
        return leftValue + rightValue;
    }
}
