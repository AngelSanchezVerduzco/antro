package com.example.bck_ms_a.dto;

import java.time.Instant;

public record PairingCodeResponse(String deviceId, String pairingCode, Instant expiresAt) {}
