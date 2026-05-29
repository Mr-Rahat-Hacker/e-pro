package com.eprocurement.erp.security;

import com.eprocurement.erp.domain.entity.PermissionEntity;
import com.eprocurement.erp.domain.entity.RoleEntity;
import com.eprocurement.erp.domain.entity.UserEntity;
import com.eprocurement.erp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class EnterpriseUserDetailsService implements UserDetailsService {
    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserEntity user = userRepository.findByUsernameIgnoreCase(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return User.withUsername(user.getUsername())
            .password(user.getPasswordHash() == null ? "" : user.getPasswordHash())
            .disabled(!user.isActive() || !"ACTIVE".equals(user.getStatus()))
            .authorities(resolveAuthorities(user))
            .build();
    }

    private Collection<GrantedAuthority> resolveAuthorities(UserEntity user) {
        Set<GrantedAuthority> authorities = new HashSet<>();
        for (RoleEntity role : user.getRoles()) {
            authorities.add(new SimpleGrantedAuthority("ROLE_" + role.getRoleCode()));
            for (PermissionEntity permission : role.getPermissions()) {
                authorities.add(new SimpleGrantedAuthority(permission.getPermissionCode()));
            }
        }
        return authorities;
    }
}
