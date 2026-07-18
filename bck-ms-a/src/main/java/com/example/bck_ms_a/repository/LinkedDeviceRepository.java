package com.example.bck_ms_a.repository;

import com.example.bck_ms_a.entity.LinkedDevice;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LinkedDeviceRepository extends JpaRepository<LinkedDevice, Long> {

    Optional<LinkedDevice> findByDeviceIdAndRevokedFalse(String deviceId);
}
