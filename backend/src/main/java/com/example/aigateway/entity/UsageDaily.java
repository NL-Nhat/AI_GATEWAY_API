package com.example.aigateway.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;

@Entity
@Table(
    name = "usage_daily", 
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "usage_date"})
    }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsageDaily {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "usage_date", nullable = false)
    private LocalDate usageDate;

    @Column(name = "total_requests", nullable = false)
    private Integer totalRequests = 0;

    @Column(name = "successful_requests", nullable = false)
    private Integer successfulRequests = 0;

    @Column(name = "failed_requests", nullable = false)
    private Integer failedRequests = 0;

    @Column(name = "total_input_tokens", nullable = false)
    private Long totalInputTokens = 0L;

    @Column(name = "total_output_tokens", nullable = false)
    private Long totalOutputTokens = 0L;

    @Column(name = "total_tokens", nullable = false)
    private Long totalTokens = 0L;

    @Column(name = "total_latency_ms", nullable = false)
    private Long totalLatencyMs = 0L;

    @Column(name = "average_latency_ms", nullable = false, precision = 12, scale = 2)
    private BigDecimal averageLatencyMs = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private ZonedDateTime updatedAt;
}
