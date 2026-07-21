<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<c:set var="arrowSvg"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg></c:set>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade"     value="${cms.isEditMode}" />
<c:set var="hasCta"  value="${value.Cta.exists and value.Cta.value.URI.isSet}" />

<section class="element type-gb-showcase std-showcase${setCssWrapperAll}" aria-label="${fn:escapeXml(value.Title)}"><%----%>
    <div class="wrap"><%----%>
        <div class="std-head" data-reveal><%----%>
            <c:if test="${value.Eyebrow.isSet}"><span class="eyebrow eyebrow--fade"><span class="dot"></span>${value.Eyebrow}</span></c:if><%----%>
            <h2 ${ade ? content.rdfa.Title : ''}>${value.Title}</h2><%----%>
        </div><%----%>

        <c:if test="${value.Image.exists}">
            <div class="std-media" data-reveal><%----%>
                <img src="<cms:link>${value.Image.value.Image}</cms:link>" alt="${fn:escapeXml(value.Image.value.Title)}" loading="lazy"><%----%>
            </div><%----%>
        </c:if>

        <c:if test="${value.Text.isSet}">
            <div class="std-text" data-reveal ${ade ? content.rdfa.Text : ''}>${value.Text}</div><%----%>
        </c:if>

        <c:if test="${hasCta}">
            <div class="std-cta" data-reveal><%----%>
                <m:link link="${value.Cta}" css="btn btn-accent"><%----%
                    %>${value.Cta.value.Text.isSet ? value.Cta.value.Text : value.Title}${arrowSvg}<%----%>
                </m:link><%----%>
            </div><%----%>
        </c:if>
    </div><%----%>
</section><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
