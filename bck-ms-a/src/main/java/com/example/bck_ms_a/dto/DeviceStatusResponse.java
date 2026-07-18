package com.example.bck_ms_a.dto;

import java.time.Instant;

public record DeviceStatusResponse(
        String status, String deviceId, Long userId, String userEmail, String deviceToken, Instant linkedAt) {

    public static DeviceStatusResponse pending(String deviceId) {
        return new DeviceStatusResponse("pending", deviceId, null, null, null, null);
    }

    public static DeviceStatusResponse linked(
            String deviceId, Long userId, String userEmail, String deviceToken, Instant linkedAt) {
        return new DeviceStatusResponse("linked", deviceId, userId, userEmail, deviceToken, linkedAt);
    }
}
