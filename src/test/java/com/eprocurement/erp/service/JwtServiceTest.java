package com.eprocurement.erp.service;

import com.eprocurement.erp.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {
    @Test
    void generatedTokenContainsSubjectAndIsValid() {
        JwtService jwtService = new JwtService(
            "test-issuer",
            "0123456789012345678901234567890123456789012345678901234567890123",
            30
        );
        UserDetails user = User.withUsername("buyer01")
            .password("unused")
            .authorities("ROLE_BUYER", "PO_CREATE")
            .build();

        String token = jwtService.generateAccessToken(user);

        assertThat(jwtService.extractUsername(token)).isEqualTo("buyer01");
        assertThat(jwtService.isTokenValid(token, user)).isTrue();
        assertThat(jwtService.expiresAt(token)).isAfter(java.time.Instant.now());
    }
}
