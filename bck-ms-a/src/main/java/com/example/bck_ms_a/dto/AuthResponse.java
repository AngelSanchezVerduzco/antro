package com.example.bck_ms_a.dto;

public record AuthResponse(String token, String tokenType, long expiresInMs, UserResponse user) {

    public AuthResponse(String token, long expiresInMs, UserResponse user) {
        this(token, "Bearer", expiresInMs, user);
    }
}
