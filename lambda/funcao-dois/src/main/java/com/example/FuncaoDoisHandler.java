package com.example;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.PutItemRequest;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class FuncaoDoisHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    private final AmazonDynamoDB dynamoDbClient;
    private final ObjectMapper objectMapper;
    private final String tableName;

    public FuncaoDoisHandler() {
        this.dynamoDbClient = AmazonDynamoDBClientBuilder.standard().build();
        this.objectMapper = new ObjectMapper();
        this.tableName = System.getenv("DYNAMODB_TABLE_NAME");
    }

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        context.getLogger().log("Processando requisição para adicionar item à lista de mercado");

        try {
            // Validação do corpo da requisição
            if (input.getBody() == null || input.getBody().trim().isEmpty()) {
                return createErrorResponse(400, "O corpo da requisição não pode estar vazio");
            }

            MarketItem item;
            try {
                item = objectMapper.readValue(input.getBody(), MarketItem.class);
            } catch (Exception e) {
                return createErrorResponse(400, "Formato JSON inválido no corpo da requisição");
            }

            // Validação do campo name
            if (item.getName() == null || item.getName().trim().isEmpty()) {
                return createErrorResponse(400, "O nome do item é obrigatório");
            }

            // Geração dos identificadores
            String itemId = UUID.randomUUID().toString();
            String pk = "LIST#" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")); // Prefixo LIST# para compatibilidade
            String sk = "ITEM#" + itemId; // Padrão de chave para itens

            // Construção do item para DynamoDB
            Map<String, AttributeValue> itemAttributes = new HashMap<>();
            itemAttributes.put("PK", new AttributeValue(pk));
            itemAttributes.put("SK", new AttributeValue(sk));
            itemAttributes.put("name", new AttributeValue(item.getName()));
            itemAttributes.put("date", new AttributeValue(LocalDate.now().toString()));
            itemAttributes.put("status", new AttributeValue("TODO")); // Padronizado para maiúsculo

            // Log para debug
            context.getLogger().log("Dados do item a ser salvo: " + itemAttributes.toString());

            // Inserção no DynamoDB
            dynamoDbClient.putItem(new PutItemRequest()
                    .withTableName(tableName)
                    .withItem(itemAttributes));

            // Construção da resposta
            Map<String, Object> responseBody = new HashMap<>();
            responseBody.put("success", true);
            responseBody.put("message", "Item adicionado com sucesso à lista de mercado");
            responseBody.put("item", Map.of(
                    "PK", pk,
                    "SK", sk,
                    "name", item.getName(),
                    "date", LocalDate.now().toString(),
                    "status", "TODO" // Consistente com o valor salvo
            ));

            return new APIGatewayProxyResponseEvent()
                    .withStatusCode(201)
                    .withBody(objectMapper.writeValueAsString(responseBody))
                    .withHeaders(Map.of("Content-Type", "application/json"));

        } catch (Exception e) {
            context.getLogger().log("Erro detalhado: " + e.toString());
            return createErrorResponse(500, "Erro interno ao processar a solicitação");
        }
    }

    private APIGatewayProxyResponseEvent createErrorResponse(int statusCode, String message) {
        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
        try {
            Map<String, Object> errorBody = Map.of(
                    "success", false,
                    "message", message
            );
            response.setStatusCode(statusCode);
            response.setBody(objectMapper.writeValueAsString(errorBody));
            response.setHeaders(Map.of("Content-Type", "application/json"));
        } catch (Exception e) {
            response.setStatusCode(500);
            response.setBody("{\"success\":false,\"message\":\"Erro interno\"}");
        }
        return response;
    }

    public static class MarketItem {
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}