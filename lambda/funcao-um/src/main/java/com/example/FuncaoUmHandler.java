package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import java.util.LinkedHashMap;
import java.util.Map;

public class FuncaoUmHandler implements RequestHandler<Object, Map<String, Object>> {

    @Override
    public Map<String, Object> handleRequest(Object input, Context context) {
        context.getLogger().log("Função Lambda em execução!");

        Map<String, Object> response = new LinkedHashMap<>();

        response.put("statusCode", 200);
        response.put("body", "Hello Terraform");

        return response;
    }
}
