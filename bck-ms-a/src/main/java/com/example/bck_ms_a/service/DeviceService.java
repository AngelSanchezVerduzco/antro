package com.example.bck_ms_a.service;

import com.example.bck_ms_a.dto.ConfirmPairingRequest;
import com.example.bck_ms_a.dto.DeviceSessionRequest;
import com.example.bck_ms_a.dto.DeviceStatusResponse;
import com.example.bck_ms_a.dto.PairingCodeResponse;
import com.example.bck_ms_a.dto.RequestPairingRequest;
import com.example.bck_ms_a.dto.UserResponse;
import com.example.bck_ms_a.entity.DevicePairingCode;
import com.example.bck_ms_a.entity.LinkedDevice;
import com.example.bck_ms_a.entity.User;
import com.example.bck_ms_a.repository.DevicePairingCodeRepository;
import com.example.bck_ms_a.repository.LinkedDeviceRepository;
import com.example.bck_ms_a.repository.UserRepository;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class DeviceService {

    private final DevicePairingCodeRepository pairingCodeRepository;
    private final LinkedDeviceRepository linkedDeviceRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;
    private final long pairingCodeTtlMinutes;
    private final SecureRandom secureRandom = new SecureRandom();

    public DeviceService(
            DevicePairingCodeRepository pairingCodeRepository,
            LinkedDeviceRepository linkedDeviceRepository,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            AuthService authService,
            @Value("${app.device.pairing-code-ttl-minutes}") long pairingCodeTtlMinutes) {
        this.pairingCodeRepository = pairingCodeRepository;
        this.linkedDeviceRepository = linkedDeviceRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authService = authService;
        this.pairingCodeTtlMinutes = pairingCodeTtlMinutes;
    }

    @Transactional
    public PairingCodeResponse requestPairing(RequestPairingRequest request) {
        String deviceId = request.deviceId().trim();
        String plainCode = generateSixDigitCode();
        Instant expiresAt = Instant.now().plus(pairingCodeTtlMinutes, ChronoUnit.MINUTES);

        DevicePairingCode pairingCode = new DevicePairingCode();
        pairingCode.setDeviceId(deviceId);
        pairingCode.setCodeHash(passwordEncoder.encode(plainCode));
        pairingCode.setExpiresAt(expiresAt);

        pairingCodeRepository.save(pairingCode);
        return new PairingCodeResponse(deviceId, plainCode, expiresAt);
    }

    @Transactional
    public UserResponse confirmPairing(String userEmail, ConfirmPairingRequest request) {
        User user = userRepository
                .findByEmailIgnoreCase(userEmail.trim().toLowerCase())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        DevicePairingCode pairingCode = findActivePairingCode(request.pairingCode())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Codigo invalido o expirado"));

        pairingCode.setUsed(true);

        String deviceToken = UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID();
        String tokenHash = passwordEncoder.encode(deviceToken);

        LinkedDevice linkedDevice = linkedDeviceRepository
                .findByDeviceIdAndRevokedFalse(pairingCode.getDeviceId())
                .orElseGet(LinkedDevice::new);

        linkedDevice.setDeviceId(pairingCode.getDeviceId());
        linkedDevice.setUser(user);
        linkedDevice.setDeviceTokenHash(tokenHash);
        linkedDevice.setDeliveryToken(deviceToken);
        linkedDevice.setRevoked(false);
        linkedDevice.setLastActiveAt(Instant.now());

        linkedDeviceRepository.save(linkedDevice);
        return authService.toUserResponse(user);
    }

    @Transactional
    public DeviceStatusResponse getStatus(String deviceId) {
        return linkedDeviceRepository
                .findByDeviceIdAndRevokedFalse(deviceId)
                .map(device -> {
                    if (device.getDeliveryToken() != null) {
                        String token = device.getDeliveryToken();
                        device.setDeliveryToken(null);
                        linkedDeviceRepository.save(device);
                        return DeviceStatusResponse.linked(
                                device.getDeviceId(),
                                device.getUser().getId(),
                                device.getUser().getEmail(),
                                token,
                                device.getLinkedAt());
                    }
                    return DeviceStatusResponse.linked(
                            device.getDeviceId(),
                            device.getUser().getId(),
                            device.getUser().getEmail(),
                            null,
                            device.getLinkedAt());
                })
                .orElseGet(() -> DeviceStatusResponse.pending(deviceId));
    }

    @Transactional
    public UserResponse validateSession(DeviceSessionRequest request) {
        LinkedDevice device = linkedDeviceRepository
                .findByDeviceIdAndRevokedFalse(request.deviceId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Dispositivo no vinculado"));

        if (!passwordEncoder.matches(request.deviceToken(), device.getDeviceTokenHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Token de dispositivo invalido");
        }

        device.setLastActiveAt(Instant.now());
        linkedDeviceRepository.save(device);
        return authService.toUserResponse(device.getUser());
    }

    @Transactional
    public void revokeDevice(String deviceId) {
        LinkedDevice device = linkedDeviceRepository
                .findByDeviceIdAndRevokedFalse(deviceId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Dispositivo no encontrado"));

        device.setRevoked(true);
        device.setDeliveryToken(null);
        linkedDeviceRepository.save(device);
    }

    private java.util.Optional<DevicePairingCode> findActivePairingCode(String plainCode) {
        Instant now = Instant.now();
        List<DevicePairingCode> pending = pairingCodeRepository.findAll().stream()
                .filter(code -> !code.isUsed() && code.getExpiresAt().isAfter(now))
                .toList();

        return pending.stream()
                .filter(code -> passwordEncoder.matches(plainCode, code.getCodeHash()))
                .findFirst();
    }

    private String generateSixDigitCode() {
        int value = secureRandom.nextInt(900_000) + 100_000;
        return String.valueOf(value);
    }
}
