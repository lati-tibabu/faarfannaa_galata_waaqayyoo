import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { MessageSquare, ThumbsUp, Trash2, Users } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { communityService } from '../services/api';
import { getUser } from '../lib/session';

const Community = () => {
  const user = getUser();
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [newPost, setNewPost] = useState({ content: '', imageUrl: '' });
  const [posting, setPosting] = useState(false);
  const [commentInputs, setCommentInputs] = useState({});

  const loadPosts = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await communityService.getPosts();
      setPosts(Array.isArray(response.data) ? response.data : []);
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to load community posts.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPosts();
  }, []);

  const handleCreatePost = async (event) => {
    event.preventDefault();
    if (!user) {
      window.alert('Create an account to post in the community.');
      return;
    }
    setPosting(true);
    setError('');
    try {
      await communityService.createPost({
        content: newPost.content.trim(),
        imageUrl: newPost.imageUrl.trim() || null,
      });
      setNewPost({ content: '', imageUrl: '' });
      await loadPosts();
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to create post.');
    } finally {
      setPosting(false);
    }
  };

  const escapeHtml = (text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

  const renderMarkdown = (raw = '') => {
    const lines = String(raw).split('\n');
    const htmlParts = [];
    let listBuffer = [];
    let listType = null;

    const flushList = () => {
      if (!listBuffer.length) return;
      const tag = listType === 'ol' ? 'ol' : 'ul';
      htmlParts.push(`<${tag}>${listBuffer.map((item) => `<li>${item}</li>`).join('')}</${tag}>`);
      listBuffer = [];
      listType = null;
    };

    const inline = (source) => {
      let text = escapeHtml(source);
      text = text.replace(/\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');
      text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
      text = text.replace(/\*(.+?)\*/g, '<em>$1</em>');
      return text;
    };

    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) {
        flushList();
        htmlParts.push('<br/>');
        continue;
      }

      const ulMatch = /^[-*]\s+(.+)$/.exec(trimmed);
      if (ulMatch) {
        if (listType && listType !== 'ul') flushList();
        listType = 'ul';
        listBuffer.push(inline(ulMatch[1]));
        continue;
      }

      const olMatch = /^\d+\.\s+(.+)$/.exec(trimmed);
      if (olMatch) {
        if (listType && listType !== 'ol') flushList();
        listType = 'ol';
        listBuffer.push(inline(olMatch[1]));
        continue;
      }

      flushList();
      if (trimmed.startsWith('### ')) {
        htmlParts.push(`<h3>${inline(trimmed.slice(4))}</h3>`);
      } else if (trimmed.startsWith('## ')) {
        htmlParts.push(`<h2>${inline(trimmed.slice(3))}</h2>`);
      } else if (trimmed.startsWith('# ')) {
        htmlParts.push(`<h1>${inline(trimmed.slice(2))}</h1>`);
      } else {
        htmlParts.push(`<p>${inline(trimmed)}</p>`);
      }
    }

    flushList();
    return htmlParts.join('');
  };

  const handleToggleLike = async (post) => {
    if (!user) {
      window.alert('Create an account to like posts.');
      return;
    }
    try {
      if (post.likedByUser) {
        await communityService.unlikePost(post.id);
      } else {
        await communityService.likePost(post.id);
      }
      await loadPosts();
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to update like.');
    }
  };

  const handleAddComment = async (postId) => {
    if (!user) {
      window.alert('Create an account to comment.');
      return;
    }
    const content = String(commentInputs[postId] || '').trim();
    if (!content) return;
    try {
      await communityService.addComment(postId, content);
      setCommentInputs((previous) => ({ ...previous, [postId]: '' }));
      await loadPosts();
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to add comment.');
    }
  };

  const handleDeletePost = async (postId) => {
    if (!user) return;
    const confirmed = window.confirm('Delete this post?');
    if (!confirmed) return;
    try {
      await communityService.deletePost(postId);
      await loadPosts();
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to delete post.');
    }
  };

  const handleDeleteComment = async (commentId) => {
    if (!user) return;
    const confirmed = window.confirm('Delete this comment?');
    if (!confirmed) return;
    try {
      await communityService.deleteComment(commentId);
      await loadPosts();
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to delete comment.');
    }
  };

  if (loading) {
    return <div className="mx-auto w-full max-w-5xl px-4 py-10 sm:px-6 lg:px-8">Loading community...</div>;
  }

  return (
    <div className="mx-auto w-full max-w-5xl px-4 py-10 sm:px-6 lg:px-8">
      <section className="mb-6 rounded-2xl border border-border/70 bg-card/75 p-6 dark:border-white/10 dark:bg-zinc-950/55">
        <h1 className="flex items-center gap-2 text-3xl font-semibold">
          <Users className="size-7 text-primary" />
          Community
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Share encouragement, post worship moments, add image links, and interact with others.
        </p>
        {!user && (
          <p className="mt-3 text-sm">
            Want to post, like, and comment? <Link to="/register" className="text-primary underline">Create an account</Link>.
          </p>
        )}
      </section>

      <Card className="mb-6 border-border/70 bg-card/80 dark:border-white/10 dark:bg-zinc-900/45">
        <CardHeader>
          <CardTitle>Create Post</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-3" onSubmit={handleCreatePost}>
            <textarea
              value={newPost.content}
              onChange={(event) => setNewPost((previous) => ({ ...previous, content: event.target.value }))}
              rows={6}
              className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              placeholder="Write your post... Markdown is supported silently (#, **bold**, *italic*, lists, [link](https://...))."
              required
            />
            <Input
              value={newPost.imageUrl}
              onChange={(event) => setNewPost((previous) => ({ ...previous, imageUrl: event.target.value }))}
              placeholder="Optional image URL (https://...)"
            />
            <Button type="submit" disabled={posting}>
              {posting ? 'Posting...' : 'Post'}
            </Button>
          </form>
        </CardContent>
      </Card>

      {error && <p className="mb-4 rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}

      <div className="space-y-4">
        {posts.map((post) => (
          <Card key={post.id} className="border-border/70 bg-card/90 dark:border-white/10 dark:bg-zinc-950/50">
            <CardHeader className="pb-2">
              <div className="flex items-center justify-between gap-2">
                <CardTitle className="text-base">
                  {post.author?.name || 'Member'} <span className="text-xs font-normal text-muted-foreground"> -  {new Date(post.createdAt).toLocaleString()}</span>
                </CardTitle>
                {user?.id && post.author?.id === user.id && (
                  <Button variant="ghost" size="sm" onClick={() => handleDeletePost(post.id)}>
                    <Trash2 className="size-4" />
                  </Button>
                )}
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              <div
                className="prose prose-sm max-w-none text-foreground prose-a:text-primary prose-strong:text-foreground dark:prose-invert"
                dangerouslySetInnerHTML={{ __html: renderMarkdown(post.content || '') }}
              />
              {post.imageUrl && (
                <img src={post.imageUrl} alt="Community post" className="max-h-96 w-full rounded-lg object-cover" />
              )}
              <div className="flex items-center gap-2">
                <Button variant={post.likedByUser ? 'default' : 'outline'} size="sm" onClick={() => handleToggleLike(post)}>
                  <ThumbsUp className="size-4" />
                  {post.likesCount}
                </Button>
                <span className="text-sm text-muted-foreground">{post.comments?.length || 0} comments</span>
              </div>

              <div className="space-y-2 rounded-lg bg-muted/40 p-3 dark:bg-white/[0.03]">
                {Array.isArray(post.comments) && post.comments.map((comment) => (
                  <div key={comment.id} className="flex items-center justify-between gap-2 text-sm">
                    <div>
                      <span className="font-medium">{comment.author?.name || 'Member'}:</span> {comment.content}
                    </div>
                    {user?.id && comment.author?.id === user.id && (
                      <Button variant="ghost" size="sm" onClick={() => handleDeleteComment(comment.id)}>
                        <Trash2 className="size-4" />
                      </Button>
                    )}
                  </div>
                ))}
                <div className="flex gap-2">
                  <Input
                    value={commentInputs[post.id] || ''}
                    onChange={(event) => setCommentInputs((previous) => ({ ...previous, [post.id]: event.target.value }))}
                    placeholder="Write a comment..."
                  />
                  <Button variant="outline" size="sm" onClick={() => handleAddComment(post.id)}>
                    <MessageSquare className="size-4" />
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default Community;

