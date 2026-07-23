package com.example.bck_ms_a.dto;

import com.example.bck_ms_a.entity.Role;
import java.time.Instant;

public record UserResponse(
        Long id,
        String email,
        String fullName,
        Role role,
        boolean enabled,
        boolean mustChangePassword,
        Instant lastLoginAt,
        Instant createdAt) {}
