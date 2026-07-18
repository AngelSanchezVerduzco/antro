package com.example.bck_ms_a.repository;

import com.example.bck_ms_a.entity.DevicePairingCode;
import java.time.Instant;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DevicePairingCodeRepository extends JpaRepository<DevicePairingCode, Long> {

    Optional<DevicePairingCode> findTopByDeviceIdAndUsedFalseAndExpiresAtAfterOrderByCreatedAtDesc(
            String deviceId, Instant now);
}
