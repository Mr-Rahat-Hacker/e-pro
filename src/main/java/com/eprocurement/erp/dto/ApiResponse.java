package com.eprocurement.erp.dto;

import java.time.OffsetDateTime;

public record ApiResponse<T>(
    boolean success,
    T data,
    String message,
    OffsetDateTime timestamp
) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null, OffsetDateTime.now());
    }

    public static <T> ApiResponse<T> created(T data, String message) {
        return new ApiResponse<>(true, data, message, OffsetDateTime.now());
    }
}
