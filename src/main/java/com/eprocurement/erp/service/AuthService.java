package com.eprocurement.erp.service;

import com.eprocurement.erp.dto.AuthRequest;
import com.eprocurement.erp.dto.AuthResponse;
import com.eprocurement.erp.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public AuthResponse login(AuthRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );
        UserDetails principal = (UserDetails) authentication.getPrincipal();
        String token = jwtService.generateAccessToken(principal);
        return new AuthResponse(
            token,
            "Bearer",
            jwtService.expiresAt(token),
            principal.getUsername(),
            principal.getAuthorities().stream().map(GrantedAuthority::getAuthority).sorted().toList()
        );
    }
}
