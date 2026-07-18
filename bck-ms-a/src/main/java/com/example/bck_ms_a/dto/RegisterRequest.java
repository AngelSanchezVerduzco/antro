package com.example.bck_ms_a.dto;

import com.example.bck_ms_a.entity.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 6, max = 100) String password,
        @NotBlank @Size(min = 2, max = 255) String fullName,
        Role role) {}
