package com.eprocurement.erp.controller;

import com.eprocurement.erp.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "Platform", description = "Platform metadata endpoints")
@RestController
@RequestMapping("/api/v1/platform")
public class PlatformController {
    @Operation(summary = "Get backend project structure summary")
    @GetMapping("/structure")
    public ApiResponse<Map<String, String>> structure() {
        return ApiResponse.ok(Map.of(
            "domain", "JPA entities and enums",
            "repository", "Spring Data repositories",
            "service", "Transactional use-case services",
            "controller", "REST API controllers and Swagger annotations",
            "security", "Spring Security JWT components",
            "exception", "Global exception handling"
        ));
    }
}
