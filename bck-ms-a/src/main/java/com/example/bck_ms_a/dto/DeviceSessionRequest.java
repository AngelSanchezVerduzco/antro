package com.example.bck_ms_a.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DeviceSessionRequest(
        @NotBlank @Size(min = 8, max = 64) String deviceId,
        @NotBlank @Size(min = 20, max = 128) String deviceToken) {}
