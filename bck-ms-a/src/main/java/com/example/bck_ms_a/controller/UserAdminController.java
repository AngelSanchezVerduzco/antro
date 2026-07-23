package com.example.bck_ms_a.controller;

import com.example.bck_ms_a.dto.UserResponse;
import com.example.bck_ms_a.service.AuthService;
import java.util.List;
import java.util.Map;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserAdminController {

    private final AuthService authService;

    public UserAdminController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping
    public Map<String, List<UserResponse>> list(Authentication authentication) {
        return Map.of("items", authService.listUsers());
    }

    @PostMapping("/{id}/disable")
    public UserResponse disable(@PathVariable Long id, Authentication authentication) {
        return authService.setEnabled(authentication.getName(), id, false);
    }

    @PostMapping("/{id}/enable")
    public UserResponse enable(@PathVariable Long id, Authentication authentication) {
        return authService.setEnabled(authentication.getName(), id, true);
    }
}
