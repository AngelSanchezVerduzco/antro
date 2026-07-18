package com.example.bck_ms_a.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RequestPairingRequest(
        @NotBlank @Size(min = 8, max = 64) String deviceId) {}
