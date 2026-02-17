const {
  CommunityPost,
  CommunityComment,
  CommunityPostLike,
  User,
} = require('../models');

const communityController = {
  getPosts: async (req, res) => {
    try {
      const posts = await CommunityPost.findAll({
        include: [
          { model: User, as: 'author', attributes: ['id', 'name'] },
          {
            model: CommunityComment,
            as: 'comments',
            include: [{ model: User, as: 'author', attributes: ['id', 'name'] }],
            order: [['createdAt', 'ASC']],
          },
          { model: CommunityPostLike, as: 'likes', attributes: ['id', 'userId'] },
        ],
        order: [['createdAt', 'DESC']],
      });

      const payload = posts.map((post) => ({
        id: post.id,
        content: post.content,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        author: post.author ? { id: post.author.id, name: post.author.name } : null,
        likesCount: Array.isArray(post.likes) ? post.likes.length : 0,
        likedByUser: req.user
          ? Boolean((post.likes || []).find((like) => like.userId === req.user.id))
          : false,
        comments: (post.comments || []).map((comment) => ({
          id: comment.id,
          content: comment.content,
          createdAt: comment.createdAt,
          author: comment.author ? { id: comment.author.id, name: comment.author.name } : null,
        })),
      }));

      return res.json(payload);
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  createPost: async (req, res) => {
    try {
      const content = String(req.body?.content || '').trim();
      if (content.length < 3) {
        return res.status(400).json({ error: 'Post content must be at least 3 characters.' });
      }

      const imageUrl = req.body?.imageUrl ? String(req.body.imageUrl).trim() : null;

      const post = await CommunityPost.create({
        userId: req.user.id,
        content,
        imageUrl: imageUrl || null,
      });

      return res.status(201).json({ message: 'Post created.', post });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  addComment: async (req, res) => {
    try {
      const post = await CommunityPost.findByPk(req.params.postId);
      if (!post) {
        return res.status(404).json({ error: 'Post not found.' });
      }

      const content = String(req.body?.content || '').trim();
      if (content.length < 2) {
        return res.status(400).json({ error: 'Comment must be at least 2 characters.' });
      }

      const comment = await CommunityComment.create({
        postId: post.id,
        userId: req.user.id,
        content,
      });

      return res.status(201).json({ message: 'Comment added.', comment });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  likePost: async (req, res) => {
    try {
      const post = await CommunityPost.findByPk(req.params.postId);
      if (!post) {
        return res.status(404).json({ error: 'Post not found.' });
      }

      await CommunityPostLike.findOrCreate({
        where: { postId: post.id, userId: req.user.id },
      });

      return res.json({ message: 'Post liked.' });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  unlikePost: async (req, res) => {
    try {
      const post = await CommunityPost.findByPk(req.params.postId);
      if (!post) {
        return res.status(404).json({ error: 'Post not found.' });
      }

      await CommunityPostLike.destroy({
        where: { postId: post.id, userId: req.user.id },
      });

      return res.json({ message: 'Post unliked.' });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  deletePost: async (req, res) => {
    try {
      const post = await CommunityPost.findByPk(req.params.postId);
      if (!post) {
        return res.status(404).json({ error: 'Post not found.' });
      }

      const isOwner = post.userId === req.user.id;
      const isAdmin = req.user.role === 'admin';
      if (!isOwner && !isAdmin) {
        return res.status(403).json({ error: 'You can only delete your own post.' });
      }

      await CommunityPost.destroy({ where: { id: post.id } });
      return res.json({ message: 'Post deleted.' });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  deleteComment: async (req, res) => {
    try {
      const comment = await CommunityComment.findByPk(req.params.commentId);
      if (!comment) {
        return res.status(404).json({ error: 'Comment not found.' });
      }

      const isOwner = comment.userId === req.user.id;
      const isAdmin = req.user.role === 'admin';
      if (!isOwner && !isAdmin) {
        return res.status(403).json({ error: 'You can only delete your own comment.' });
      }

      await CommunityComment.destroy({ where: { id: comment.id } });
      return res.json({ message: 'Comment deleted.' });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },
};

module.exports = communityController;
