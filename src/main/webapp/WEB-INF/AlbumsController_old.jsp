package org.superbiz.moviefun.albums;

import org.apache.tika.Tika;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import org.superbiz.moviefun.blobstore.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Optional;

import static java.lang.ClassLoader.getSystemResource;
import static java.lang.String.format;
import static java.nio.file.Files.readAllBytes;

@Controller
@RequestMapping("/albums")
public class AlbumsController_old {

    private final AlbumsBean albumsBean;

    private final BlobStore store;

    public AlbumsController_old(AlbumsBean albumsBean, BlobStore store) {
        this.albumsBean = albumsBean;
        this.store = store;
    }


    @GetMapping
    public String index(Map<String, Object> model) {
        model.put("albums", albumsBean.getAlbums());
        return "albums";
    }

    @GetMapping("/{albumId}")
    public String details(@PathVariable long albumId, Map<String, Object> model) {
        model.put("album", albumsBean.find(albumId));
        return "albumDetails";
    }

    @PostMapping("/{albumId}/cover")
    public String uploadCover(@PathVariable long albumId, @RequestParam("file") MultipartFile uploadedFile) throws IOException {


        InputStream inputStream = uploadedFile.getInputStream();
        Blob blob = new Blob(""+albumId, inputStream, "image");


        store.put(blob);

        //saveUploadToFile(uploadedFile, getCoverFile(albumId));

        return format("redirect:/albums/%d", albumId);
    }

    @GetMapping("/{albumId}/cover")
    public HttpEntity<byte[]> getCover(@PathVariable long albumId) throws IOException, URISyntaxException {
        Optional<Blob> ob = store.get(""+albumId);
        Path coverFilePath = getExistingCoverPath(albumId);
        byte[] imageBytes = readAllBytes(coverFilePath);



        HttpHeaders headers = createImageHttpHeaders(coverFilePath, imageBytes);

        return new HttpEntity<>(imageBytes, headers);
    }

    private void saveUploadToFile1(@RequestParam("file") MultipartFile uploadedFile, File targetFile) throws IOException {
        targetFile.delete();
        targetFile.getParentFile().mkdirs();
        targetFile.createNewFile();

        try (FileOutputStream outputStream = new FileOutputStream(targetFile)) {
            outputStream.write(uploadedFile.getBytes());
        }
    }


    private File getCoverFile(@PathVariable long albumId) {
        String coverFileName = format("covers/%d", albumId);
        Optional<Blob> op = null;

        try {
            FileStore store = new FileStore();
            op = store.get(coverFileName.toString());

        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }

        return new File(coverFileName);
    }



    private HttpHeaders createImageHttpHeaders(Path coverFilePath, byte[] imageBytes) throws IOException {
        String contentType = new Tika().detect(coverFilePath);
        System.out.println("generating image");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(contentType));
        headers.setContentLength(imageBytes.length);
        return headers;
    }


    private Path getExistingCoverPath(@PathVariable long albumId) throws URISyntaxException {
        File coverFile = getCoverFile(albumId);
        Path coverFilePath;

        System.out.println("[Debug]: " + coverFile.toPath());

        if (coverFile.exists()) {
            coverFilePath = coverFile.toPath();

        } else {
            coverFilePath = Paths.get(getSystemResource("default-cover.jpg").toURI());
        }

        return coverFilePath;
    }
}
