async function isLoggedInAndAdmin() {
    const { data: { user } } = await client.auth.getUser();
    let isAdmin = false;
    if (user) {
    const { data: admin } = await client.from('admins').select('*').eq('id', user.id).single();
        if (admin) {
            isAdmin = true;
        } else {
            await client.auth.signOut();
        }
    }

    if (isAdmin) {
        return true;
    }
    else {
        window.location.href = 'admin_homepage.html'
        return false;
    }

}