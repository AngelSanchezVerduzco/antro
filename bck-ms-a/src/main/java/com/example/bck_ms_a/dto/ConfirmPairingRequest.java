package com.example.bck_ms_a.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record ConfirmPairingRequest(
        @NotBlank @Pattern(regexp = "\\d{6}") String pairingCode) {}
