package com.example.bck_ms_a.controller;

import com.example.bck_ms_a.dto.ConfirmPairingRequest;
import com.example.bck_ms_a.dto.DeviceSessionRequest;
import com.example.bck_ms_a.dto.DeviceStatusResponse;
import com.example.bck_ms_a.dto.PairingCodeResponse;
import com.example.bck_ms_a.dto.RequestPairingRequest;
import com.example.bck_ms_a.dto.UserResponse;
import com.example.bck_ms_a.service.DeviceService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/device")
public class DeviceController {

    private final DeviceService deviceService;

    public DeviceController(DeviceService deviceService) {
        this.deviceService = deviceService;
    }

    @PostMapping("/request-pairing")
    public PairingCodeResponse requestPairing(@Valid @RequestBody RequestPairingRequest request) {
        return deviceService.requestPairing(request);
    }

    @PostMapping("/confirm-pairing")
    public UserResponse confirmPairing(
            Authentication authentication, @Valid @RequestBody ConfirmPairingRequest request) {
        return deviceService.confirmPairing(authentication.getName(), request);
    }

    @GetMapping("/status")
    public DeviceStatusResponse status(@RequestParam String deviceId) {
        return deviceService.getStatus(deviceId);
    }

    @PostMapping("/validate-session")
    public UserResponse validateSession(@Valid @RequestBody DeviceSessionRequest request) {
        return deviceService.validateSession(request);
    }

    @PostMapping("/revoke")
    public void revoke(@Valid @RequestBody RequestPairingRequest request) {
        deviceService.revokeDevice(request.deviceId());
    }
}
