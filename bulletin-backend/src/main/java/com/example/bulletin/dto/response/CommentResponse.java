package com.example.bulletin.dto.response;

import com.example.bulletin.entity.Comment;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class CommentResponse {

    private Long id;
    private String content;
    private String author;
    private Long authorId;
    private LocalDateTime createdAt;

    public static CommentResponse from(Comment comment) {
        return CommentResponse.builder()
                .id(comment.getId())
                .content(comment.getContent())
                .author(comment.getUser().getUsername())
                .authorId(comment.getUser().getId())
                .createdAt(comment.getCreatedAt())
                .build();
    }
}
